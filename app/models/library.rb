class Library < ApplicationRecord
    def self.ransackable_attributes(auth_object = nil)
        ["formal", "url_pc", "address", "tel", "post", "geocode", "libkey"]
      end
end
