require "uri"
require "net/http"
require "json"
require "dotenv"
require "logger"

Dotenv.load(File.expand_path("../../../.env", __FILE__))

class BookSearch
  RAKUTEN_BOOKS_APPLICATION_ID = ENV["RAKUTEN_BOOKS_APPLICATION_ID"] # 環境変数から楽天ブックスAPIのアプリケーションIDを取得
  RAKUTEN_BOOKS_API_URL = "https://app.rakuten.co.jp/services/api/BooksBook/Search/20170404" # 楽天ブックスAPIのエンドポイント

  def self.fetch_books(search_term, search_type = :keyword) # search_type のデフォルトを :keyword に変更
    puts "RAKUTEN_BOOKS_APPLICATION_ID: #{ENV['RAKUTEN_BOOKS_APPLICATION_ID'].inspect}" # デバッグ出力: RAKUTEN_BOOKS_APPLICATION_ID の値
    puts "RAKUTEN_BOOKS_APPLICATION_ID.present?: #{RAKUTEN_BOOKS_APPLICATION_ID.present?}" # デバッグ出力: RAKUTEN_BOOKS_APPLICATION_ID が存在するかどうか
    puts "search_term: #{search_term}, search_type: #{search_type}" # デバッグ出力: 検索キーワードと検索タイプ

    return [] unless RAKUTEN_BOOKS_APPLICATION_ID.present? # アプリケーションIDがない場合は空配列を返す

    books = []

    begin
      query = build_query(search_term, search_type) # クエリを生成
      puts "API Request URI: #{query}" # デバッグ出力: APIリクエストURI

      response = fetch_api_response(query) # APIレスポンスを取得
      puts "API Response Code: #{response.code}" # デバッグ出力: APIレスポンスコード

      if response.is_a?(Net::HTTPSuccess) # 成功レスポンスの場合のみ処理
        json_response = JSON.parse(response.body)
        items = json_response["Items"] || [] # items が nil の場合を考慮

        puts "Number of items in response: #{items.count}" # デバッグ出力: レスポンスに含まれるアイテム数

        items.each do |item_data| # 各書籍アイテムを処理
          book_info = parse_book_item(item_data["Item"]) # item_data['Item'] を渡すように修正
          if book_info # book_info が nil でない場合のみ処理
            books << book_info
            puts "Book added: #{book_info[:title]}" # デバッグ出力: 追加された書籍タイトル
          end
        end
      else # エラーレスポンスの場合
        Logger.new(STDOUT).error "楽天ブックスAPIエラー: #{response.code} #{response.message}" # エラーログ出力
      end
    rescue => e # エラーハンドリング
      Rails.logger.error "楽天ブックスAPIリクエスト中のエラー: #{e.message}" # 例外ログ出力
    end

    puts "fetch_books finished. Total books found: #{books.count}" # デバッグ出力: fetch_books 終了、合計書籍数
    books # 検索結果の書籍リストを返す
  end

  private

  def self.build_query(search_term, search_type)
    params = {
      applicationId: RAKUTEN_BOOKS_APPLICATION_ID, # 楽天ブックスAPIのアプリケーションID
      format: "json", # レスポンス形式をJSONに指定
      keyword: search_term, # 検索キーワード
      # title: search_term, # タイトル検索 (keyword で包括的に検索するため title は不要)
      # author: search_term, # 著者名検索 (keyword で包括的に検索するため author は不要)
      sort: "-sales", # 売れ筋順にソート (オプション)
      hits: 30 # 取得件数 (オプション)
    }

    if search_type == :title # 検索タイプが title の場合
      params[:title] = search_term # タイトルを検索キーワードに設定 (keyword と title の両方で検索)
      params.delete(:keyword) # keyword パラメータを削除 (タイトル検索時は keyword は不要)
    elsif search_type == :author # 検索タイプが author の場合
      params[:author] = search_term # 著者を検索キーワードに設定 (keyword と author の両方で検索)
      params.delete(:keyword) # keyword パラメータを削除 (著者名検索時は keyword は不要)
    end

    URI::HTTPS.build(
      host: URI.parse(RAKUTEN_BOOKS_API_URL).host,
      path: URI.parse(RAKUTEN_BOOKS_API_URL).path,
      query: URI.encode_www_form(params)
    )
  end


  def self.fetch_api_response(uri)
    Net::HTTP.get_response(uri)
  rescue => e
    Rails.logger.error "API request failed: #{e.message}"
    Net::HTTPResponse.new("500", { "Content-Type" => "application/json" }, "API request failed") # 失敗を示すレスポンスを返す
  end


  def self.parse_book_item(item)
    return nil unless item # item が nil の場合は nil を返す

    book_info = {
      title: item["title"], # 商品タイトル
      author: item["author"], # 著者名
      publisherName: item["publisherName"], # 出版社名
      isbn: item["isbn"], # ISBNコード (ISBN13)
      listPrice: item["listPrice"], # 定価 (税抜き)
      mediumImageUrl: item["mediumImageUrl"], # 商品画像URL (128x128ピクセル)
      affiliateUrl: item["affiliateUrl"], # アフィリエイトURL (楽天アフィリエイトリンク)
      itemUrl: item["itemUrl"], # 商品URL (楽天ブックスの商品ページへのリンク)
      salesDate: item["salesDate"], # 発売日 (YYYY年MM月DD日形式)
      itemCaption: item["itemCaption"], # 商品説明
      booksGenreId: item["booksGenreId"], # ジャンルID
      reviewAverage: item["reviewAverage"], # レビュー平均点 (0.0～5.0)
      reviewCount: item["reviewCount"] # レビュー件数
    }
    puts "Parsed book_info: #{book_info}" # デバッグ出力: 解析された書籍情報
    book_info # book_info を返す
  end
end


if __FILE__ == $0 # 直接実行された場合のみ実行
  search_term = ARGV[0] || "ruby" # 検索キーワードをコマンドライン引数から取得 (デフォルト: 'ruby')
  search_type = ARGV[1]&.to_sym || :keyword # 検索タイプをコマンドライン引数から取得 (デフォルト: :keyword)

  if search_term.nil? || search_term.empty?
    puts "Usage: ruby book_search.rb <search_term> [search_type]"
    puts "  search_type: keyword (default), title, or author" # 検索タイプの選択肢を keyword, title, author に変更
    exit 1
  end

  puts "Searching for '#{search_term}' by #{search_type}..." # 検索開始メッセージ

  books = BookSearch.fetch_books(search_term, search_type) # 書籍情報を取得 (クラス名を修正)

  if books.empty?
    puts "No books found for '#{search_term}' by #{search_type}." # 検索結果が0件の場合
  else
    puts "\nFound #{books.count} books:" # 検索結果が見つかった場合
    books.each_with_index do |book, index| # 各書籍情報を出力
      puts "\n--- Book #{index + 1} ---"
      puts "Title: #{book[:title]}" # タイトル
      puts "Author: #{book[:author]}" # 著者名
      puts "Publisher: #{book[:publisherName]}" # 出版社名
      puts "ISBN: #{book[:isbn]}" # ISBNコード
      puts "List Price: #{book[:listPrice]}" # 定価
      puts "Image URL: #{book[:mediumImageUrl]}" # 画像URL
      puts "Affiliate URL: #{book[:affiliateUrl]}" # アフィリエイトURL
      puts "Item URL: #{book[:itemUrl]}" # 商品URL
      puts "Sales Date: #{book[:salesDate]}" # 発売日
      puts "Item Caption: #{book[:itemCaption]}" # 商品説明
      puts "Genre ID: #{book[:booksGenreId]}" # ジャンルID
      puts "Review Average: #{book[:reviewAverage]}" # レビュー平均点
      puts "Review Count: #{book[:reviewCount]}" # レビュー件数
    end
  end
end
