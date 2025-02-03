require 'uri'
require 'net/http'
require 'json'

class BookSearch
  # CARIL_API_URL = "https://api.carel.jp/v1/books" # カーリルAPIのURLは使用しない
  OPENBD_API_URL = "https://api.openbd.jp/v1/get"

  def self.fetch_data(search_term, search_type = :title)
    # 検索タイプに応じてISBNをOpenBD APIで検索 (タイトル/著者名検索はOpenBDではISBN検索に変換する必要がある)
    isbn_list = fetch_isbn_list_from_openbd(search_term, search_type) # ISBNリストをOpenBDから取得するメソッド (後述)

    books = []
    isbn_list.each do |isbn| # 取得したISBNリストを元に書籍情報を取得
      book_info = fetch_book_info_from_openbd(isbn) # ISBNから書籍情報をOpenBDから取得するメソッド (後述)
      if book_info # 書籍情報が取得できた場合のみ追加
        books << {
          title: book_info['title'],
          author: book_info['author'],
          publisher: book_info['publisher'],
          isbn: isbn,
          image_link: book_info['cover'] # OpenBDからカバー画像を取得
        }
      end
    end

    # ISBNが存在する書籍のみを返す
    books.select { |book| book[:isbn] }.sort_by { |book| book[:title] }
  end

  # OpenBD API を使用して ISBN リストを取得するメソッド (例: タイトル/著者名検索 -> ISBN 検索)
  def self.fetch_isbn_list_from_openbd(search_term, search_type)
    # OpenBD API ではタイトルや著者名での直接検索はサポートされていないため、
    # ISBN 検索に変換する処理が必要 (例: Web API を組み合わせて ISBN を取得するなど)
    # ここでは簡易的に空の ISBN リストを返す (実際には実装が必要)
    Rails.logger.warn("OpenBD API ではタイトル/著者名での直接検索はサポートされていません。ISBN 検索に変換する処理を実装してください。")
    return [] 
  end

  # OpenBD API を使用して ISBN から書籍情報を取得するメソッド
  def self.fetch_book_info_from_openbd(isbn)
    uri = URI("#{OPENBD_API_URL}?isbn=#{isbn}")
    response = Net::HTTP.get_response(uri)
    return nil unless response.is_a?(Net::HTTPSuccess)

    books_data = JSON.parse(response.body)
    book_info = books_data.first
    if book_info # 書籍情報が存在する場合
      return { # 必要な情報を Hash で返す
        title: book_info['summary']['title'],
        author: book_info['summary']['author'],
        publisher: book_info['summary']['publisher'],
        cover: book_info['summary']['cover']
      }
    else
      return nil # 書籍情報が存在しない場合は nil を返す
    end
  end
end