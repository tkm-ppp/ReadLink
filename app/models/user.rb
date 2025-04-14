class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

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

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name   # 必要に応じてnameカラムを追加
      # user.image = auth.info.image # 必要なら画像も保存
    end
  end
end