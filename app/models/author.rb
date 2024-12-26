class Author < ApplicationRecord
    has_many :book_authors, class_name: 'BookAuthor'
    has_many :books, through: :book_authors

    validates :name, presence: true
    validates :is_representative, inclusion: { in: [true, false] }  # trueまたはfalseであることを確認
  
    # 代表著者かどうかを確認するメソッド
    def representative?
      is_representative
    end
  end