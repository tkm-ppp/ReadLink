class BooksController < ApplicationController
  def create
    ndl_search = Kokkaitosyokanapi.new
    books = ndl_search.get_book_info(create_book_params[:title], create_book_params[:author])
    
    if books.any?
      @book = books.first
      
      # 各属性を設定
      @book.info_link = @book.info_link if @book.info_link.present?
      @book.publisher = @book.publisher if @book.publisher.present?
      @book.published_date = @book.published_date if @book.published_date.present?
      @book.image_link = @book.image_link if @book.image_link.present?
      @book.page_count = @book.page_count if @book.page_count.present?
      @book.rating = @book.rating if @book.rating.present?
      @book.description = @book.description if @book.description.present?
      @book.isbn = @book.isbn if @book.isbn.present?

      if @book.save_with_author
        redirect_to @book
      else
        redirect_to search_books_path, alert: '本の保存に失敗しました'
      end
    else
      redirect_to search_books_path, alert: '本が見つかりませんでした'
    end
  end

  def show
    @book = Book.find(params[:id])
    @search_params = params[:search]
  rescue ActiveRecord::RecordNotFound
    redirect_to search_books_path, alert: '本が見つかりませんでした'
  end

  def search
    @books = Kaminari.paginate_array([]).page(1).per(20)
    
    if params[:search].present?
      page = params[:page] || 1
      per_page = 20
      
      ndl_search = Kokkaitosyokanapi.new
      books = ndl_search.get_book_info(params[:search], nil, page.to_i, per_page)
      
      if books.present?
        books_array = books.reject { |book| book.isbn.nil? }.uniq(&:isbn).map do |book|
          existing_book = Book.find_or_initialize_by(isbn: book.isbn)
          existing_book.assign_attributes(
            title: book.title,
            author: book.author,
            publisher: book.publisher,
            info_link: book.info_link,
            description: book.description,
            image_link: book.cover_url,
            published_date: book.published_date # 追加
          )
          existing_book.save if existing_book.changed?
          existing_book
        end
        
        @books = Kaminari.paginate_array(
          books_array,
          total_count: books_array.length
        ).page(page).per(per_page)
      end
    end
  end

  private

  def create_book_params
    params.require(:book).permit(:title, :creator, :publisher, :isbn, :info_link, :published_date) # 追加
  end

  def book_params
    params.require(:book).permit(:title, :creator, :publisher, :isbn, :info_link, :published_date) # 追加
  end
end
