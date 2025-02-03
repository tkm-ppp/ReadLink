require 'uri'
require 'net/http'
require 'nokogiri'
require 'json' # JSONパーサーを追加

class ApiFetcher
  OPENSEARCH_API_URL = "https://ndlsearch.ndl.go.jp/api/opensearch"
  COVER_API_BASE_URL = "https://ndlsearch.ndl.go.jp/thumbnail"
  CARIL_API_BASE_URL = "https://api.calil.jp/book"


  def self.fetch_data(search_term)
    uri = URI(OPENSEARCH_API_URL)
    uri.query = URI.encode_www_form(
      title: search_term,
    )
    response = Net::HTTP.get_response(uri)
    response_body_utf8 = response.body.force_encoding('UTF-8')

    puts "レスポンスコード: #{response.code}" # レスポンスコードを確認
    puts "レスポンスボディ: #{response_body_utf8}" # レスポンスボディを確認

    doc = Nokogiri::XML(response_body_utf8)
    items = doc.xpath('/rss/channel/item')
    filtered_items = []

    # 検索結果が存在しない場合の処理
    if doc.at_xpath('/rss/channel/openSearch:totalResults').text.to_i == 0
      puts "検索結果が見つかりませんでした。"
    else
      items.each do |item|
        categories = item.xpath('category')
        if categories.any? { |category| category.content == '図書' }
          title = item.at_xpath('title')&.content
          author = item.at_xpath('author')&.content
          if title && title.include?(search_term) || author && author.include?(search_term)
            book_info = parse_ndl_item(item)
            if book_info[:isbn].present? && CurilApiClient.book_exists?(book_info[:isbn]) # カーリルAPIで存在確認
              filtered_items << book_info
            end
          end
        end
      end
    end
    filtered_items
  end

  def self.parse_ndl_item(item)
    {
      title: item.at_xpath('title')&.content,
      author: item.at_xpath('author')&.content,
      publisher: item.at_xpath('dc:publisher')&.content,
      info_link: item.at_xpath('link')&.content,
      published_date: item.at_xpath('dc:date')&.content,
      isbn: item.at_xpath('dc:identifier')&.content&.gsub('ISBN:', ''),
      image_link: "#{COVER_API_BASE_URL}/#{item.at_xpath('dc:identifier')&.content&.gsub('ISBN:', '')}"
    }
  end
  
  class CurilApiClient
    CARIL_API_BASE_URL = "https://api.calil.jp/check"
    CARIL_APP_KEY = ENV['CARIL_APP_KEY'] # APIキー (必要な場合)
  
    def self.book_exists?(isbn)
      return false if isbn.blank?
  
      uri = URI(CARIL_API_BASE_URL)
      uri.query = URI.encode_www_form(
        appkey: CARIL_APP_KEY,
        isbn: isbn,
        format: 'jsonp', 
        callback: 'callback' # コールバック関数名 (固定値)
      )
  
      response = Net::HTTP.get_response(uri)
  
      case response
      when Net::HTTPSuccess
        json_response_string = response.body
        if json_response_string.start_with?('callback(') && json_response_string.end_with?(');')
          json_string = json_response_string.delete_prefix('callback(').delete_suffix(');')
          Rails.logger.debug "Response Body (JSON after conversion): #{json_string}"
          begin
            json_response = JSON.parse(json_string)
            # 存在判定ロジックを修正: レスポンスが空でなければ存在するとみなす (仮実装)
            return json_response.present? && json_response.any? 
          rescue JSON::ParserError => e
            Rails.logger.error "JSONパースエラー (JSONP変換後): #{e.message}"
            return false
          end
        else
          Rails.logger.warn "JSONP形式のレスポンスではありません: #{json_response_string}"
          return false
        end
  
      else
        Rails.logger.error "カーリルAPIエラー: #{response.code} #{response.message}"
        false
      end
    rescue => e
      Rails.logger.error "カーリルAPIリクエストエラー: #{e.message}"
      false
    end
  end
end
