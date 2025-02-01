require 'uri'
require 'net/http'
require 'nokogiri'
require 'json'

class BookSearch
  CARIL_API_URL = "https://api.calil.jp/check"
  OPENBD_API_URL = "https://api.openbd.jp/v1/get"

  def self.fetch_data(search_term, search_type = :title)
    # 検索タイプに応じてクエリパラメータを設定
    query_param = search_type == :author ? { author: search_term } : { title: search_term }
    
    # カーリルAPIを使用してデータを取得
    uri = URI(CARIL_API_URL)
    uri.query = URI.encode_www_form(query_param)
    response = Net::HTTP.get_response(uri)
  
    # JSONP形式からJSON形式に変換 (callback() が付いている場合)
    json_response = response.body
    if json_response.start_with?('callback(') && json_response.end_with?(');')
      json_response = json_response.delete_prefix('callback(').delete_suffix(');')
    end
  
    # JSONデータをパース
    begin
      books_data = JSON.parse(json_response)
    rescue JSON::ParserError => e
      # JSONパースに失敗した場合のエラーハンドリング
      puts "JSON parse error: #{e.message}"
      return []
    end
  
    # 書籍情報を取得
    books = books_data.map do |book_info|
      isbn = book_info['isbn']
      {
        title: book_info['title'],
        author: book_info['author'],
        publisher: book_info['publisher'],
        isbn: isbn,
        image_link: fetch_cover_image(isbn)
      }
    end
  
    # ISBNが存在する書籍のみを返す
    books.select { |book| book[:isbn] }.sort_by { |book| book[:title] }
  end
  
end
