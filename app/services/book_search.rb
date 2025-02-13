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

  # 検索タイプを廃止し、title_keyword と author_keyword を引数として受け取るように変更
  def self.fetch_books(title_keyword = nil, author_keyword = nil)
    return [] if RAKUTEN_APPLICATION_ID.nil? || RAKUTEN_APPLICATION_ID.empty?
    puts "fetch_books started with title_keyword: #{title_keyword}, author_keyword: #{author_keyword}" # デバッグ出力: fetch_books 開始

    books = []
    page = 1 # ページ番号初期化

    begin
      loop do # ページネーションループ
        # build_query の引数を変更
        query = build_query(title_keyword, author_keyword, RAKUTEN_APPLICATION_ID, page) # クエリを生成

        response = fetch_api_response(query) # APIレスポンスを取得

        puts "API Response Code: #{response.code}" # デバッグ出力: APIレスポンスコード

        if response.is_a?(Net::HTTPSuccess) # HTTPステータスコードが 2xx の場合のみ処理
          json_response = JSON.parse(response.body)
          items = json_response["Items"] || [] # Items が nil の場合を考慮

          puts "Number of items in response: #{items.count}" # デバッグ出力: レスポンスに含まれるアイテム数

          items.each do |item_data| # 各書籍アイテムを処理
            book_item = item_data["Item"] # Item 要素を取得
            book_info = parse_book_item(book_item) # パース処理
            if book_info && !book_info[:isbn].nil? && !book_info[:isbn].empty? && matches_search_criteria?(book_info, title_keyword, author_keyword) # マッチング処理を修正
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

  # build_query の引数を変更、検索タイプによる条件分岐を削除
  def self.build_query(title_keyword, author_keyword, application_id, page)
    params = {
      applicationId: application_id, # アプリケーションID
      format: "json", # レスポンス形式をJSONに指定
      hits: HITS_PER_PAGE, # 1ページあたり取得件数
      page: page # ページ番号
    }

    # title_keyword が存在する場合、title パラメータを追加
    params[:title] = title_keyword if title_keyword.present?
    # author_keyword が存在する場合、author パラメータを追加
    params[:author] = author_keyword if author_keyword.present?


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

  # matches_search_criteria? メソッドを修正
  def self.matches_search_criteria?(book_info, title_keyword, author_keyword)
    # title_keyword が指定されている場合はタイトルで比較
    if !title_keyword.nil? && book_info[:title].downcase.include?(title_keyword.downcase)
      return true if author_keyword.nil?
    end
  
    # author_keyword が指定されている場合は著者名で比較
    if !author_keyword.nil? && book_info[:authors].downcase.include?(author_keyword.downcase)
      return true if title_keyword.nil?
    end
  
    # title_keyword と author_keyword の両方が指定されている場合は両方で比較
    if !title_keyword.nil? && !author_keyword.nil? &&
       book_info[:title].downcase.include?(title_keyword.downcase) && book_info[:authors].downcase.include?(author_keyword.downcase)
      return true
    end
  
    # どちらのキーワードも指定されていない場合は常に true (全件取得)
    return true if title_keyword.nil? && author_keyword.nil?
  
    false 
  end
end


if __FILE__ == $0 # 直接実行された場合のみ実行
  # コマンドライン引数の処理を変更
  title_keyword = ARGV[0] # タイトルキーワードを最初の引数から取得
  author_keyword = ARGV[1] # 著者名キーワードを2番目の引数から取得


  if title_keyword.nil? && author_keyword.nil?
    puts "Usage: ruby book_search.rb <title_keyword> [author_keyword]"
    puts "  <title_keyword>: 書籍タイトル (省略可)"
    puts "  <author_keyword>: 著者名 (省略可)"
    puts "  タイトルまたは著者名のどちらか、または両方を指定して検索できます。"
    exit 1
  end

  search_criteria_message = ""
  search_criteria_message += "タイトル: '#{title_keyword}' " if title_keyword.present?
  search_criteria_message += "著者名: '#{author_keyword}' " if author_keyword.present?

  puts "Searching for books by #{search_criteria_message}using Rakuten Books API..."

 
  books = BookSearch.fetch_books(title_keyword, author_keyword) 

  if books.empty?
    puts "No books found for #{search_criteria_message}using Rakuten Books API."
  else
    puts "\nFound #{books.count} books from Rakuten Books API:"
    books.each_with_index do |book, index| 
      puts "\n--- Book #{index + 1} ---"
      puts "Title: #{book[:title]}"
      puts "Author: #{book[:authors]}" 
      puts "Publisher: #{book[:publisher]}" 
      puts "ISBN: #{book[:isbn]}"
      puts "Image Link: #{book[:image_link]}" 
    end
  end
end