require "uri"
require "net/http"
require "json"
require "dotenv"
require "logger"

Dotenv.load(File.expand_path("../../../.env", __FILE__))

class BookSearch
  RAKUTEN_APPLICATION_ID = ENV["RAKUTEN_APPLICATION_ID"] # 環境変数からアプリケーションIDを取得
  RAKUTEN_BOOKS_API_URL = "https://app.rakuten.co.jp/services/api/BooksBook/Search/20170404" # 楽天Books APIのエンドポイント
  HITS_PER_PAGE = 30 # 楽天APIの1ページあたり最大取得件数 (30件)

  def self.fetch_books(search_term, search_type = :title)
    return [] if RAKUTEN_APPLICATION_ID.nil? || RAKUTEN_APPLICATION_ID.empty? # アプリケーションIDが設定されていない場合は空配列を返す
    puts "fetch_books started with search_term: #{search_term}, search_type: #{search_type}" # デバッグ出力: fetch_books 開始

    books = []
    page = 1 # ページ番号初期化

    begin
      loop do # ページネーションループ
        query = build_query(search_term, search_type, RAKUTEN_APPLICATION_ID, page) # クエリを生成

        response = fetch_api_response(query) # APIレスポンスを取得

        puts "API Response Code: #{response.code}" # デバッグ出力: APIレスポンスコード

        if response.is_a?(Net::HTTPSuccess) # HTTPステータスコードが 2xx の場合のみ処理
          json_response = JSON.parse(response.body)
          items = json_response["Items"] || [] # Items が nil の場合を考慮
          
          puts "Number of items in response: #{items.count}" # デバッグ出力: レスポンスに含まれるアイテム数

          items.each do |item_data| # 各書籍アイテムを処理
            book_item = item_data["Item"] # Item 要素を取得
            book_info = parse_book_item(book_item) # パース処理
            if book_info && !book_info[:isbn].nil? && !book_info[:isbn].empty? && matches_search_term?(book_info, search_term, search_type)
              books << book_info
              puts "Book added: #{book_info[:title]}" # デバッグ出力: 追加された書籍タイトル
            end
          end

          total_count = json_response["count"].to_i # 総ヒット件数を取得
          if books.count >= total_count || books.count >= 100 # 最大100件まで、または総ヒット件数を超えたら終了
            puts "Reached max books or total count. Stopping pagination."
            break # 最大件数に達した場合、または総ヒット件数を超えた場合はループを抜ける
          end

          page += 1 # ページ番号をインクリメント
          puts "Next Page: #{page}" # デバッグ出力: 次のページ番号

          sleep 1 # API rate limit 対策 (調整可能)
        else # HTTPエラーレスポンスの場合
          Logger.new(STDOUT).error "Rakuten Books API error: #{response.code} #{response.message}"
          break # エラーが発生した場合はループを抜ける (リトライしない)
        end
      end # loop do
    rescue => e # エラーハンドリング
      Rails.logger.error "Error during Rakuten Books API request: #{e.message}"
    end

    puts "fetch_books finished. Total books found: #{books.count}" # デバッグ出力: fetch_books 終了、合計書籍数
    books # 検索結果の書籍リストを返す
  end


  private

  def self.build_query(search_term, search_type, application_id, page)
    params = {
      applicationId: application_id, # アプリケーションID
      format: "json", # レスポンス形式をJSONに指定
      keyword: search_term, # 検索キーワード
      hits: HITS_PER_PAGE, # 1ページあたり取得件数
      page: page # ページ番号
    }
    
    # 検索タイプに応じてパラメータを追加
    case search_type
    when :title
      params[:title] = search_term # タイトル検索
    when :author
      params[:author] = search_term # 著者名検索
    when :publisher
      params[:publisherName] = search_term # 出版社名検索
    when :isbn
      params[:isbn] = search_term # ISBN検索
    end


    URI::HTTPS.build(host: URI.parse(RAKUTEN_BOOKS_API_URL).host, path: URI.parse(RAKUTEN_BOOKS_API_URL).path, query: URI.encode_www_form(params))
  end


  def self.fetch_api_response(uri)
    Net::HTTP.get_response(uri)
  rescue => e
    Rails.logger.error "API request failed: #{e.message}"
    Net::HTTPResponse.new("500", { "Content-Type" => "application/json" }, "API request failed") # 失敗を示すレスポンスを返す
  end


  def self.parse_book_item(item)
    book_info = {
      title: item["title"], # タイトル
      authors: item["author"], # 著者名 (楽天APIのレスポンスに authors はないので author を使用)
      publisher: item["publisherName"], # 出版社名
      isbn: item["isbn"], # ISBN
      image_link: item["mediumImageUrl"] # 画像URL (medium サイズ)
    }
    puts "Parsed book_info: #{book_info}" # デバッグ出力: 解析された書籍情報
    book_info
  end

  def self.matches_search_term?(book_info, search_term, search_type)
    # 楽天APIではキーワード検索を使用しているため、追加のマッチング処理は基本的には不要
    true # 常に true を返す
  end
end


if __FILE__ == $0 # 直接実行された場合のみ実行
  search_term = ARGV[0] || "ruby" # 検索キーワードをコマンドライン引数から取得 (デフォルト: 'ruby')
  search_type = ARGV[1]&.to_sym || :title # 検索タイプをコマンドライン引数から取得 (デフォルト: :title)

  if search_term.nil? || search_term.empty?
    puts "Usage: ruby book_search.rb <search_term> [search_type]"
    puts "  search_type: title (default), author, publisher, isbn"
    exit 1
  end

  puts "Searching for '#{search_term}' by #{search_type} using Rakuten Books API..." # 検索開始メッセージ

  books = BookSearch.fetch_books(search_term, search_type) # 書籍情報を取得

  if books.empty?
    puts "No books found for '#{search_term}' by #{search_type} using Rakuten Books API." # 検索結果が0件の場合
  else
    puts "\nFound #{books.count} books from Rakuten Books API:" # 検索結果が見つかった場合
    books.each_with_index do |book, index| # 各書籍情報を出力
      puts "\n--- Book #{index + 1} ---"
      puts "Title: #{book[:title]}"
      puts "Author: #{book[:authors]}" # 著者名 (authors -> Author に変更)
      puts "Publisher: #{book[:publisher]}" # 出版社名 (publisher -> publisherName に変更)
      puts "ISBN: #{book[:isbn]}"
      puts "Image Link: #{book[:image_link]}" # 画像URL (image_link -> mediumImageUrl に変更)
    end
  end
end