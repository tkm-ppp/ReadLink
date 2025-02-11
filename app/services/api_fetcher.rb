require 'uri'
require 'net/http'
require 'nokogiri'
require 'json' # JSONパーサーを追加

class ApiFetcher
  OPENSEARCH_API_URL = "https://ndlsearch.ndl.go.jp/api/opensearch"
  COVER_API_BASE_URL = "https://ndlsearch.ndl.go.jp/thumbnail"
  OPENBD_API_URL = "https://api.openbd.jp/v1/get" # OpenBD APIのURL

  def self.fetch_data(search_term)
    uri = URI(OPENSEARCH_API_URL)
    uri.query = URI.encode_www_form(
      title: search_term,
    )
    response = Net::HTTP.get_response(uri)
    response_body_utf8 = response.body.force_encoding('UTF-8')

    doc = Nokogiri::XML(response_body_utf8)
    items = doc.xpath('/rss/channel/item')
    filtered_items = []

    # 検索結果が存在しない場合の処理
    if doc.at_xpath('/rss/channel/openSearch:totalResults').text.to_i == 0
      puts "NDL Search API: 検索結果が見つかりませんでした。"
    else
      items.each do |item|
        categories = item.xpath('category')
        if categories.any? { |category| category.content == '図書' }
          title = item.at_xpath('title')&.content
          author = item.at_xpath('author')&.content
          if title && title.include?(search_term) || author && author.include?(search_term)
            book_info = parse_ndl_item(item)
            if OpenBdApiClient.book_exists_in_openbd?(book_info[:isbn]) # OpenBD APIで存在確認
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

  class OpenBdApiClient # クラス名を変更
    OPENBD_API_URL = "https://api.openbd.jp/v1/get" # OpenBD APIのURL

    def self.book_exists_in_openbd?(isbn) # メソッド名を変更
      return false if isbn.blank?

      uri = URI("#{OPENBD_API_URL}?isbn=#{isbn}")
      response = Net::HTTP.get_response(uri)
      response_body_utf8 = response.body.force_encoding('UTF-8')


      case response
      when Net::HTTPSuccess
        json_response = JSON.parse(response_body_utf8)
        # OpenBD APIのレスポンスが空配列の場合、データが存在しないと判断する
        return json_response.present? && json_response.any?
      else

        return false
      end
    rescue => e

      return false
    end
  end
end