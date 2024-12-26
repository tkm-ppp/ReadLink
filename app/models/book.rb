class Book < ApplicationRecord
  has_many :book_authors, class_name: 'BookAuthor'
  has_many :authors, through: :book_authors

  attr_writer :creator
  attr_accessor :info_link, :author, :isbn

  def initialize(attributes = nil)
    super
    if attributes.is_a?(Hash)
      # セッターメソッドを使用
      self.title = attributes['title']
      self.publisher = attributes['publisher']
      self.info_link = attributes['info_link']
      self.published_date = attributes['publishedDate'] 
      self.image_link = attributes['imageLinks'] ? attributes['imageLinks']['thumbnail'] : nil 
      self.page_count = attributes['pageCount'] 
      self.rating = attributes['averageRating'] 
      self.description = attributes['description'] 
      self.isbn = attributes['isbn']
      
      # 著者の処理
      if self.author.present?
        author_names = self.author.split(',').map(&:strip)
        self.authors = author_names.map { |name| Author.find_or_initialize_by(name: name) }
      end
    end
  end

  def save_with_author(authors = nil)
    authors ||= [@creator].flatten.compact if @creator

    ActiveRecord::Base.transaction do
      self.save!
      if authors.present?
        authors.each do |name|
          next if name.blank?
          author = Author.find_or_initialize_by(name: name.strip)
          author.save!
          self.authors << author unless self.authors.include?(author)
        end
      end
    end
    true
  rescue StandardError => e
    Rails.logger.error "Error saving book with authors: #{e.message}"
    false
  end

  def to_s
    "Title: #{title}\nCreator: #{creator || authors.pluck(:name).join(', ')}\nPublisher: #{publisher}\nISBN: #{isbn}"
  end

  def cover_url
    return nil unless isbn.present?
    "#{Kokkaitosyokanapi::BASE_URL}/thumbnail/#{isbn}.jpg"
  end
end
