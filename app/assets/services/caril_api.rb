# app/services/caril_api.rb
require 'httparty'

class CarilApi
  include HTTParty
  base_uri 'https://api.calil.jp'

  def initialize(api_key)
    @api_key = 	7c854f40b6a4274618da08219f6c60e0    
  end

  def search_books(keyword)
    self.class.get("/book/search", query: { appkey: @api_key, keyword: keyword })
  end
end
