class BooksController < ApplicationController
  include GoogleBooksApi
  require 'addressable/uri'
  # before_action :set_caril_api, only: [:search]  # search メソッドの前に API インスタンスを設定

  def create
    @book = current_user.books.build(book_params)
    if @book.save_with_author(authors_params[:authors])
      redirect_to books_path, success: t('.success')
    else
      flash.now[:danger] = t('.fail')
    end
  end

  def show
    # URLパラメータから本のIDを取得
    book_id = params[:id]

    # Google Books APIから本の詳細情報を取得
    url = "https://www.googleapis.com/books/v1/volumes/#{book_id}"
    res = Faraday.get(url)

    if res.success?
      @book_details = JSON.parse(res.body)
  
      # 必要な情報を抽出
      @title = @book_details.dig('volumeInfo', 'title')
      @image_link = @book_details.dig('volumeInfo', 'imageLinks', 'thumbnail') # サムネイル画像を取得
      @info_link = @book_details.dig('volumeInfo', 'infoLink')
      @published_date = @book_details.dig('volumeInfo', 'publishedDate')
      @publisher = @book_details.dig('volumeInfo', 'publisher')
      @page_count = @book_details.dig('volumeInfo', 'pageCount')
      @rating = @book_details.dig('volumeInfo', 'averageRating')
      @description = @book_details.dig('volumeInfo', 'description')
      
      # ジャンルについては別途管理が必要
      @genre = nil # 必要に応じて設定する
    else
      Rails.logger.error "API Error: #{res.status} - #{res.body}"
      flash[:danger] = "本の詳細を取得できませんでした。"
      redirect_to books_path and return
    end
  end

  def search
    @book = Book.new

    if params[:search].blank?
      flash.now[:danger] = "検索キーワードが入力されていません"
      return
    end

    url = url_of_searching_from_keyword(params[:search])  # モジュールメソッドを利用
    encoded_url = Addressable::URI.parse(url).normalize.to_s

    res = Faraday.get(encoded_url)

    # ステータスコードを確認
    if res.success?
      @google_books = JSON.parse(res.body)
      if @google_books['items'].nil?
        flash.now[:warning] = "検索結果が見つかりませんでした"
      end
    else
      Rails.logger.error "API Error: #{res.status} - #{res.body}"
      flash.now[:danger] = "API エラーが発生しました: #{res.status} - #{res.body}"
      return
    end

    @availability = {}

    # ここで図書館IDを取得するためのメソッドを呼び出す
    # libraries = get_library_ids  # 図書館IDを取得

    # @google_books['items']&.each do |google_book|
    #   isbn = google_book.dig("volumeInfo", "industryIdentifiers")&.find { |id| id["type"] == "ISBN_13" }&.dig("identifier")
    #   if isbn
    #     availability_response = @caril_api.check_availability(isbn, libraries)  # インスタンス変数を使用
    #     @availability[google_book['id']] = availability_response
    #   end
    # end

    # Rails.logger.debug "API Response: #{@availability.inspect}"  # availabilityの結果をデバッグログに出力
  end

  private

  # def set_caril_api
  #   @caril_api = CarilApi.new(ENV['CALIL_API_KEY'])  # 環境変数からAPIキーを取得してインスタンスを作成
  # end

  # def get_library_ids
  #   # ここで図書館データベースから図書館IDを取得する
  #   response = @caril_api.nearby_libraries(35.681236, 139.767125)  # 例: 東京駅の緯度経度を使用
  #   libraries = response.map { |library| library['systemid'] }  # systemidを配列に格納
  #   libraries
  # rescue => e
  #   Rails.logger.error "Error fetching library IDs: #{e.message}"
  #   []  # エラーが発生した場合は空の配列を返す
  # end

  def book_params
    params.require(:book).permit(
      :title,
      :image_link,
      :info_link,
      :published_date,
      :google_books_api_id,
      :publisher,
      :page_count,
      :rating,
      :genre,
      :description
    )
  end

  def authors_params
    params.require(:book).permit(authors: [])
  end
end