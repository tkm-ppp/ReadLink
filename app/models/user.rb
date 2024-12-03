class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # Deviseのモジュールを含める
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :books

  # バリデーション
  validates :email, presence: { message: "メールアドレスは必須です" }, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "メールアドレスの形式が正しくありません" }

  validates :password, presence: true, length: { minimum: 6, message: "パスワードは6文字以上である必要があります" }
  validates :password_confirmation, presence: true

  validates :name, presence: true, uniqueness: true


  # usernameもnameを参照
  validates :username, presence: true, uniqueness: true, if: -> { name.present? }

  # コールバックを正しく設定
  before_validation :set_username

  private

  def set_username
    self.username = name if username.blank?
  end

  # カスタムバリデーション
end
