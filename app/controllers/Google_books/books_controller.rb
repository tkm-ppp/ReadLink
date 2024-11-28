class BooksController < ApplicationController
  def create
    @book = current_user.books.build(book_params)
    #モデルに書いたsave_with_authorメソッドを実行する
    if @book.save_with_author(authors_params[:authors])
      redirect_to books_path, success: t('.success')
    else
      flash.now[:danger] = t('.fail')
    end
  end

  def index
  end

  def show
  end

  def search
    if params[:search].nil?
      nil
    elsif params[:search].blank?
      flash.now[:danger] = "検索キーワードが入力されていません"
      nil
    else
      url = "https://www.googleapis.com/books/v1/volumes"
      text = params[:search]
      res = Faraday.get(url, q: text, langRestrict: "ja", maxResults: 20)
      @google_books = JSON.parse(res.body)
    end
  end
end
