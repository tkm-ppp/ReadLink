module GoogleBooksApi
  require 'addressable/uri'

  def url_of_creating_from_id(googlebooksapi_id)
    "https://www.googleapis.com/books/v1/volumes/#{googlebooksapi_id}"
  end
  #  Google Books APIのIDから、APIのURLを取得する

  def url_of_searching_from_keyword(keyword)
    base_url = 'https://www.googleapis.com/books/v1/volumes'
    query_params = { q: keyword, country: 'JP' }
    uri = Addressable::URI.parse(base_url)
    uri.query_values = query_params
    uri.to_s
  end
 
  def get_json_from_url(url)
    JSON.parse(Net::HTTP.get(URI.parse(url)))
  end
  #  URLから、JSON文字列を取得し、JSONオブジェクトを構築する
end
  