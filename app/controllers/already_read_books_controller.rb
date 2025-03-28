class AlreadyReadBooksController < ApplicationController
  before_action :authenticate_user! # ログインユーザーのみアクセス可能にする
  before_action :set_book, only: [:create, :destroy]

  def index
    @already_read_books = current_user.already_read_books
  end

  def create
    @already_read_book = current_user.already_read_books.build(isbn: @isbn)

    respond_to do |format|
      if @already_read_book.save
        format.turbo_stream { render turbo_stream: turbo_stream.replace("already_read_#{@isbn}", partial: 'already_read_books/button', locals: { isbn: @isbn }) }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.append("flash", partial: "shared/error_messages", locals: { message: "登録に失敗しました" }) }
      end
    end
  end

  def destroy
    @already_read_book = current_user.already_read_books.find_by(isbn: @isbn)
    
    if @already_read_book
      @already_read_book.destroy
      
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove("already_read_#{@isbn}"),
            turbo_stream.append("flash", partial: "shared/error_messages", locals: { message: "削除に成功しました" })
          ]
        end
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.append("flash", partial: "shared/error_messages", locals: { message: "削除に失敗しました" }) }
      end
    end
  end

  private

  def set_book
    @isbn = params[:isbn]
  end
end