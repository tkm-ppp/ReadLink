class GoogleBook
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations
  
    attribute :google_books_api_id, :string
    attribute :authors, :string, default: ""
    attribute :image, :string
    attribute :published_date, :date
    attribute :title, :string
  
    validates :google_books_api_id, presence: true
    validates :title, presence: true
    validates :authors, presence: true  # authorsのバリデーションを追加
  
    class << self
      include GoogleBooksApi
  
      def new_from_item(item)
        volume_info = item['volumeInfo']
        authors = volume_info['authors'] || []  # nilの場合は空の配列を設定
  
        new(
          google_books_api_id: item['id'],
          authors: authors.join(", "),  # authorsを文字列として保存
          image: image_url(volume_info),
          published_date: volume_info['publishedDate'],
          title: volume_info['title']
        )
      end
  
      def new_from_id(google_books_api_id)
        url = url_of_creating_from_id(google_books_api_id)
        item = get_json_from_url(url)
        new_from_item(item)
      end
  
      def search(keyword)
        url = url_of_searching_from_keyword(keyword)
        json = get_json_from_url(url)
        items = json['items']
        return [] unless items
  
        items.map { |item| new_from_item(item) }
      end
  
      private
  
      def image_url(volume_info)
        volume_info.dig('imageLinks', 'smallThumbnail')
      end
    end
  
    def save_to_database
      book = Book.find_or_initialize_by(google_books_api_id: google_books_api_id)
      book.assign_attributes(
        title: title,
        published_date: published_date,
        image_link: image
      )
  
      if book.save
        save_authors(book, authors.split(", "))  # authorsを配列に戻して保存
        book
      else
        Rails.logger.error("Failed to save book: #{book.errors.full_messages}")
        nil
      end
    end
  
    private
  
  def save_authors(book, authors)
    authors.each do |author_name|
      next if author_name.blank?

      author = Author.find_or_initialize_by(name: author_name.strip)
      author.books << book unless author.books.include?(book)

      unless author.save
        Rails.logger.error("Failed to save author: #{author.errors.full_messages}")
      end
    end
  end 
end 