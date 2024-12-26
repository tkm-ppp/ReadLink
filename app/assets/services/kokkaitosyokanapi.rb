require 'faraday'
require 'nokogiri'
require_relative 'book'

class Kokkaitosyokanapi
  BASE_URL = 'https://iss.ndl.go.jp'.freeze

  def get_book_info(title, creator = nil)
    query = {
      mediatype: 1,
      cnt: 10,
      title: title,
      creator: creator
    }.compact

    response = ndl_get('/api/opensearch', query)
    parse_response(response.body)
  end

  def get_book_cover(isbn)
    "#{BASE_URL}/thumbnail/#{isbn}.jpg"
  end

  private

  def ndl_get(path, params)
    Faraday.new(url: BASE_URL) do |f|
      f.request :url_encoded
      f.response :logger
      f.adapter Faraday.default_adapter
    end.get(path, params)
  end

  def parse_response(body)
    xml = Nokogiri::XML(body)
    xml.remove_namespaces!
    xml.xpath('/rss/channel/item').map do |item|
      Book.new(parse_item(item))
    end
  end

  def parse_item(item)
    book_data = {}
    item.children.each do |c|
      next if c.name == 'text'
      key = c.name
      val = c.content.strip
      label = c.attribute('type')&.value&.gsub(/^dcndl:|^dcterms:/, '')

      if label
        book_data[label] ||= []
        book_data[label] << val unless book_data[label].include?(val)
      end

      book_data[key] ||= []
      book_data[key] << val unless book_data[key].include?(val)
    end
    book_data.transform_values { |v| v.join(', ') }
  end
end
