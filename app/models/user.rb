class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :user_libraries, dependent: :destroy
  has_many :libraries, through: :user_libraries
  has_many :want_to_read_books, dependent: :destroy
  has_many :already_read_books, dependent: :destroy

  def library_ids
    libraries.pluck(:id)
  end

  def library_ids=(ids)
    self.libraries = Library.where(id: ids)
  end
end