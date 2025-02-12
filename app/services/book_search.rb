require "uri"
require "net/http"
require "json"
require "dotenv"
require "logger"

Dotenv.load(File.expand_path("../../../.env", __FILE__))

class BookSearch
  GOOGLE_BOOKS_API_KEYS = ENV["GOOGLE_BOOKS_API_KEYS"]&.split(",") || [] # 環境変数からAPIキーを取得 (カンマ区切り)
  GOOGLE_BOOKS_API_URL = "https://www.googleapis.com/books/v1/volumes"
  MAX_RESULTS_PER_PAGE = 40 # Google Books API の最大取得件数 (40件)

  def self.fetch_books(search_term, search_type = :title)
    puts "GOOGLE_BOOKS_API_KEYS: #{ENV['GOOGLE_BOOKS_API_KEYS'].inspect}" # デバッグ出力: GOOGLE_BOOKS_API_KEYS の値
    puts "GOOGLE_BOOKS_API_KEYS.empty?: #{GOOGLE_BOOKS_API_KEYS.empty?}" # デバッグ出力: GOOGLE_BOOKS_API_KEYS が空かどうか
    puts "API Keys Array: #{GOOGLE_BOOKS_API_KEYS.inspect}" # デバッグ出力: APIキー配列の中身

    return [] if GOOGLE_BOOKS_API_KEYS.empty?
    puts "fetch_books started with search_term: #{search_term}, search_type: #{search_type}" # デバッグ出力: fetch_books 開始

    return [] if GOOGLE_BOOKS_API_KEYS.empty? # APIキーが設定されていない場合は空配列を返す

    api_key_rotator = ApiKeyRotator.new(GOOGLE_BOOKS_API_KEYS) # APIキーローテーターを初期化
    books = []
    page_token = nil # ページトークン初期化

    begin
      loop do # ページネーションループ
        api_key = api_key_rotator.get_next_key # APIキーをローテーション
        query = build_query(search_term, search_type, api_key, page_token) # クエリを生成

        puts "API Request URI: #{query}" # デバッグ出力: APIリクエストURI

        response = fetch_api_response(query) # APIレスポンスを取得

        puts "API Response Code: #{response.code}" # デバッグ出力: APIレスポンスコード

          # if response.is_a?(Net::HTTPSuccess) # ← この条件分岐を削除
          json_response = JSON.parse(response.body)
          items = json_response["items"] || [] # items が nil の場合を考慮

          puts "Number of items in response: #{items.count}" # デバッグ出力: レスポンスに含まれるアイテム数

          items.each do |item| # 各書籍アイテムを処理
            book_info = parse_book_item(item)
            if book_info && !book_info[:isbn].nil? && !book_info[:isbn].empty? && matches_search_term?(book_info, search_term, search_type)
              books << book_info
              puts "Book added: #{book_info[:title]}" # デバッグ出力: 追加された書籍タイトル
            end
          end

          next_page_token = json_response["nextPageToken"] # 次のページトークンを取得
          if next_page_token.nil? # 次のページがない場合はループを抜ける
            break
          else
            page_token = next_page_token # ページトークンを更新して次のページへ
            puts "Next Page Token: #{page_token}" # デバッグ出力: 次のページトークン
          end

          if books.count >= 100 # 最大100件まで取得 (調整可能)
            puts "100 books reached, stopping pagination."
            break
          end

          Logger.new(STDOUT).error "Google Books API error: #{response.code} #{response.message}"
          api_key_rotator.mark_key_as_failed(api_key) # APIキーを失敗としてマーク
          if api_key_rotator.all_keys_failed? # すべてのAPIキーが失敗した場合
            Rails.logger.error "All API keys failed. Stopping requests."
            break # リクエストを停止
          else
            puts "Retrying with a different API key." # 別のAPIキーでリトライ
          end
        sleep 1 # API rate limit 対策 (調整可能)
      end # loop do
    rescue => e # エラーハンドリング
      Rails.logger.error "Error during Google Books API request: #{e.message}"
    end

    puts "fetch_books finished. Total books found: #{books.count}" # デバッグ出力: fetch_books 終了、合計書籍数
    books # 検索結果の書籍リストを返す
  end


  private

  def self.build_query(search_term, search_type, api_key, page_token)
    query_string = search_type == :author ? "inauthor:#{search_term}" : "intitle:#{search_term}"
    params = {
      q: query_string,
      key: api_key,
      maxResults: MAX_RESULTS_PER_PAGE,
      startIndex: 0, # startIndex は Google Books API では nextPageToken でページネーションするため不要
      pageToken: page_token # ページトークンを追加
    }
    URI::HTTPS.build(host: URI.parse(GOOGLE_BOOKS_API_URL).host, path: URI.parse(GOOGLE_BOOKS_API_URL).path, query: URI.encode_www_form(params))
  end


  def self.fetch_api_response(uri)
    Net::HTTP.get_response(uri)
  rescue => e
    Rails.logger.error "API request failed: #{e.message}"
    Net::HTTPResponse.new("500", { "Content-Type" => "application/json" }, "API request failed") # 失敗を示すレスポンスを返す
  end


  def self.parse_book_item(item)
    volume_info = item["volumeInfo"]
    return nil unless volume_info # volumeInfo が nil の場合は nil を返す

    book_info = { # 一旦 book_info 変数に格納
      title: volume_info["title"],
      authors: volume_info["authors"]&.join(", "), # 著者を ',' 区切りで連結
      publisher: volume_info["publisher"],
      isbn: volume_info["industryIdentifiers"]&.find { |id| id["type"] == "ISBN_13" }&.dig("identifier"), # 修正: dig('identifier') を追加
      image_link: volume_info["imageLinks"]&.dig("thumbnail") # imageLinks から thumbnail を取得
    }
    puts "Parsed book_info: #{book_info}" # デバッグ出力: 解析された書籍情報
    book_info # book_info を返す
  end


  def self.matches_search_term?(book_info, search_term, search_type)
    if search_type == :author
      book_info[:authors]&.downcase&.include?(search_term.downcase)
    else # search_type == :title (デフォルト)
      book_info[:title]&.downcase&.include?(search_term.downcase)
    end
  end
end


class ApiKeyRotator
  def initialize(api_keys)
    @api_keys = api_keys
    @key_index = 0
    @failed_keys = {} # 失敗したAPIキーを記録するHash
  end

  def get_next_key
    key = @api_keys[@key_index]
    puts "Using API key: #{key} (index: #{@key_index})" # デバッグ出力: 使用するAPIキー
    key
  end

  def mark_key_as_failed(key)
    @failed_keys[key] = true # 失敗したAPIキーを記録
    @key_index = (@key_index + 1) % @api_keys.length # 次のキーへローテーション
    puts "Marked API key as failed: #{key}. Rotated to next key. Current index: #{@key_index}" # デバッグ出力: APIキー失敗とローテーション
  end

  def all_keys_failed?
    @failed_keys.length == @api_keys.length # すべてのAPIキーが失敗した場合 true
  end
end



if __FILE__ == $0 # 直接実行された場合のみ実行
  search_term = ARGV[0] || "ruby" # 検索キーワードをコマンドライン引数から取得 (デフォルト: 'ruby')
  search_type = ARGV[1]&.to_sym || :title # 検索タイプをコマンドライン引数から取得 (デフォルト: :title)

  if search_term.nil? || search_term.empty?
    puts "Usage: ruby book_search.rb <search_term> [search_type]"
    puts "  search_type: title (default) or author"
    exit 1
  end

  puts "Searching for '#{search_term}' by #{search_type}..." # 検索開始メッセージ

  books = GoogleBooksSearch.fetch_books(search_term, search_type) # 書籍情報を取得

  if books.empty?
    puts "No books found for '#{search_term}' by #{search_type}." # 検索結果が0件の場合
  else
    puts "\nFound #{books.count} books:" # 検索結果が見つかった場合
    books.each_with_index do |book, index| # 各書籍情報を出力
      puts "\n--- Book #{index + 1} ---"
      puts "Title: #{book[:title]}"
      puts "Authors: #{book[:authors]}"
      puts "Publisher: #{book[:publisher]}"
      puts "ISBN: #{book[:isbn]}"
      puts "Image Link: #{book[:image_link]}"
    end
  end
end
