class Book < ApplicationRecord
  has_many :book_authors
  has_many :authors, through: :book_authors
  belongs_to :user

  def save_with_author(authors)
    ActiveRecord::Base.transaction do
      self.save!
      unless authors.nil?
        self.authors = authors.uniq.reject(&:blank?).map do |name|
          Author.find_or_initialize_by(name: name.strip)
        end
      end
    end
    true
  rescue StandardError
    false
  end
end