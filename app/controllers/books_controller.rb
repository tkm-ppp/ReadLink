require_relative "../services/book_search"
require_relative "../services/data_processor"


class BooksController < ApplicationController
  def search
    if params[:search_term].present?
      @books = ApiFetcher.fetch_data(params[:search_term])
      return render(status: :bad_request) if @books.blank? # 検索結果が空の場合はBadRequestを返す

      @books = @books.map do |book|
        {
          title: book[:title],
          author: book[:author],
          image_link: book[:image_link],
          isbn: book[:isbn]
        }
      end.select { |book| book[:isbn].present? }



      csv_filename = Rails.root.join("tmp", "search_results_#{Time.now.to_i}.csv")
      DataProcessor.save_to_csv(@books, csv_filename)
      @books = DataProcessor.read_from_csv(csv_filename)
    else
      @books = []
    end
  end

  def show
    @isbn = params[:isbn] # ルーティングパラメータから ISBN を取得
    if @isbn.present?
      @availability_results = LibraryFetcher.fetch_book_details(@isbn) # 貸出状況を取得 (変更なし)
      if @availability_results[:error] # エラーメッセージが含まれているか確認 (変更なし)
        flash.now[:alert] = @availability_results[:error] # エラーメッセージを flash に設定 (変更なし)
        @availability_results = nil # ビューでエラー表示を処理しやすくするために nil を設定 (変更なし)
      end

      @book = LibraryFetcher.fetch_book_detail_from_openbd(@isbn) # 書籍詳細情報を取得

    else
      flash.now[:alert] = "ISBN が指定されていません。" # ISBN がない場合のエラーメッセージ (変更なし)
    end
  end
end
