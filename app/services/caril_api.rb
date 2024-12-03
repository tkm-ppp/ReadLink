require 'net/http'
require 'json'
require 'uri'

class CarilApi
  BASE_URL = 'https://api.calil.jp/v1' # カーリルAPIの基本URL

  def initialize(api_key)
    @api_key = ENV['CALIL_API_KEY']
  end

  # 蔵書検索メソッド
  def check_availability(isbn, libraries)
    # endpoint = '/check'
    # uri = URI("#{BASE_URL}#{endpoint}")
    # params = {
    #   appkey: @api_key,
    #   isbn: isbn,
    #   format: 'json'
    # }
    # uri.query = URI.encode_www_form(params)

    # response = Net::HTTP.get_response(uri)
    # Rails.logger.info "API Response: #{response.body}"

    @availability = {}
    
    # 複数の図書館IDを指定（例: "Tokyo_Setagaya"など）
    libraries = ["library_id1", "library_id2"] 

    # if response.is_a?(Net::HTTPSuccess)
    #   JSON.parse(response.body)
    # else
    #   Rails.logger.error "API Error: #{response.code} - #{response.body}"
    #   raise "API Error: #{response.code} - #{response.body}"
    # end
  end

  # 図書館データベースメソッド
  def nearby_libraries(lat, lon)
    # endpoint = '/library'
    # uri = URI("#{BASE_URL}#{endpoint}")
    # params = {
    #   appkey: @api_key,
    #   lat: lat,
    #   lon: lon,
    #   format: 'json'
    # }
    # uri.query = URI.encode_www_form(params)

    # response = Net::HTTP.get(uri)
    # JSON.parse(response)
  end
end

