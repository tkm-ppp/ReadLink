class WantToReadBooksController < ApplicationController
  before_action :authenticate_user! # ログインユーザーのみアクセス可能にする
  before_action :set_book, only: [:create, :destroy]

  def index
    @want_to_read_books = current_user.want_to_read_books
  end

  def create
    @want_to_read_book = current_user.want_to_read_books.build(isbn: @isbn)

    respond_to do |format|
      if @want_to_read_book.save
        format.turbo_stream { render turbo_stream: turbo_stream.replace("want_to_read_#{@isbn}", partial: 'want_to_read_books/button', locals: { isbn: @isbn }) }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.append("flash", partial: "shared/error_messages", locals: { message: "登録に失敗しました" }) }
      end
    end
  end

  def destroy
    @want_to_read_book = current_user.want_to_read_books.find_by(isbn: @isbn)
    if @want_to_read_book
      begin
        @want_to_read_book.destroy
        respond_to do |format|
          format.turbo_stream { render turbo_stream: turbo_stream.replace("want_to_read_#{@isbn}", partial: 'want_to_read_books/button', locals: { isbn: @isbn }) }
        end
      rescue ActiveRecord::RecordNotDestroyed
        respond_to do |format|
          format.turbo_stream { render turbo_stream: turbo_stream.append("flash", partial: "shared/error_messages", locals: { message: "削除に失敗しました" }) }
        end
      end
    end
  end

  private

  def set_book
    @isbn = params[:isbn]
  end
end