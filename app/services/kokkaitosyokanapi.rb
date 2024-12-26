require 'faraday'
require 'faraday/follow_redirects'
require 'faraday_middleware'
require 'nokogiri'

class Kokkaitosyokanapi
  BASE_URL = 'https://iss.ndl.go.jp'.freeze

  def initialize(dpid = 'iss-ndl-opac')
    @data_provider_id = dpid
  end

  def get_book_info(title, creator = nil, page = 1, per_page = 20)
    start_index = (page - 1) * per_page + 1

    query = {
      dpid: @data_provider_id,
      title: title,
      creator: creator,
      cnt: per_page,    # 1回のリクエストで取得する件数
      idx: start_index, # 取得開始位置
    }.compact

    response = ndl_get('/api/opensearch', qu  ery)
    parse_response(response.body) if response
  end

  # ISBNに基づいて書籍のカバー画像URLを取得する
  def get_book_cover(isbn)
    return nil unless isbn && !isbn.empty?

    "#{BASE_URL}/thumbnail/#{isbn}.jpg"
  end

  private

  def ndl_get(path, params)
    Rails.logger.debug("Sending request to #{BASE_URL}#{path} with params: #{params.inspect}")

    response = Faraday.new(url: BASE_URL) do |f|
      f.use FaradayMiddleware::FollowRedirects # リダイレクトを自動的に追跡
      f.request :url_encoded
      f.response :logger
      f.adapter Faraday.default_adapter
    end.get(path, params)

    unless response.success?
      Rails.logger.error("API request failed with status: #{response.status}")
      Rails.logger.error("Response headers: #{response.headers.inspect}")
      Rails.logger.error("Response body: #{response.body}")
      raise "API request failed with status: #{response.status}"
    end

    response
  end

  def parse_response(body)
    xml = Nokogiri::XML(body)
    xml.remove_namespaces!
    items = xml.xpath('/rss/channel/item')

    Rails.logger.debug("Items found: #{items.size}")  # アイテムの数を出力

    items.map { |item| Book.new(parse_item(item)) }
  end

  def parse_item(item)
    book_data = {}
    item.children.each do |c|
      next if c.name == 'text'

      # linkノードの場合はinfo_linkとして保存
      if c.name == 'link'
        book_data['info_link'] = c.content.strip
        next
      end

      key = c.name
      val = c.content.strip
      label = c.attribute('type')&.value&.gsub(/^dcndl:|^dcterms:/, '')

      if label
        book_data[label] ||= []
        book_data[label] << val unless book_data[label].include?(val)
      else
        book_data[key] = val unless key == 'text'
      end
    end

    # Book モデルの属性に合わせてデータを整形
    {
      'title' => book_data['title']&.first,
      'author' => Array(book_data['creator']).join(', '),
      'publisher' => book_data['publisher']&.first,
      'isbn' => book_data['ISBN']&.first || book_data['ISBN13']&.first,
      'info_link' => book_data['info_link'],
      'description' => book_data['description']&.first,
      'published_date' => book_data['date']&.first,
      'image_link' => item.at_xpath('cover')&.content&.strip,
    }.compact
  end
end
