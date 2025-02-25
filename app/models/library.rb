class Library < ApplicationRecord
  has_many :user_libraries, dependent: :destroy
  has_many :users, through: :user_libraries

    def self.ransackable_attributes(auth_object = nil)
      [ "formal", "address", "libkey" ]
    end

    def self.ransackable_associations(auth_object = nil)
      [ "user_libraries", "users" ]
    end

 
end
