class CarilApi
  include HTTParty
  base_uri 'https://api.calil.jp'

  def initialize(api_key)
    @api_key = api_key
  end

  def search_books(keyword)
    self.class.get("/book/search", query: { appkey: @api_key, keyword: keyword })
  end

  def check_availability(isbn)
    self.class.get("/book/availability", query: { appkey: @api_key, isbn: isbn })
  end
end