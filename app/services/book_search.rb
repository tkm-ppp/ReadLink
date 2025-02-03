require 'uri'
require 'net/http'
require 'json'

class BookSearch
  API_KEY_1 = 'YOUR_API_KEY_1'
  API_KEY_2 = 'YOUR_API_KEY_2'
  API_KEY_3 = 'YOUR_API_KEY_3' # 複数のAPIキーを追加

  def self.search_books(search_term)
    api_keys = [API_KEY_1, API_KEY_2, API_KEY_3]
    results = []

    api_keys.each do |api_key|
      uri = URI("https://www.googleapis.com/books/v1/volumes")
      uri.query = URI.encode_www_form(
        q: "#{search_term}", # 検索語
        key: api_key # APIキー
      )

      response = Net::HTTP.get_response(uri)
      json_response = JSON.parse(response.body)

      if json_response['totalItems'] > 0
        json_response['items'].each do |item|
          book_info = parse_book_info(item)
          results << book_info
        end
      end
    end

    results
  end

  def self.parse_book_info(item)
    {
      title: item['volumeInfo']['title'],
      authors: item['volumeInfo']['authors'],
      publisher: item['volumeInfo']['publisher'],
      published_date: item['volumeInfo']['publishedDate'],
      isbn: item['volumeInfo']['industryIdentifiers'].find { |id| id['type'] == 'ISBN_13' }&.dig('identifier')
    }
  end
end

# 検索語を指定して本の情報を取得
search_term = '人間失格'
results = BookSearch.search_books(search_term)

# 結果を表示
puts "検索結果:"
results.each do |book|
  puts "タイトル: #{book[:title]}"
  puts "著者: #{book[:authors].join(', ')}"
  puts "出版社: #{book[:publisher]}"
  puts "出版日: #{book[:published_date]}"
  puts "ISBN: #{book[:isbn]}"
  puts "------------------------"
end
