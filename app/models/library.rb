class Library < ApplicationRecord
  has_many :user_libraries, dependent: :destroy
  has_many :users, through: :user_libraries

    def self.ransackable_attributes(auth_object = nil)
      [ "formal", "address", "libkey" ]
    end

    def self.ransackable_associations(auth_object = nil)
      [ "user_libraries", "users" ]
    end

    scope :search, ->(query) { where("formal LIKE ? OR address LIKE ?", "%#{query}%", "%#{query}%") }

  # 地球の半径 (km)
  EARTH_RADIUS = 6371

  # 現在地から近い図書館を検索する
  def self.near_libraries(current_latitude, current_longitude, limit = 10)
    # ラジアンに変換
    current_lat_rad = current_latitude.to_f * Math::PI / 180
    current_lng_rad = current_longitude.to_f * Math::PI / 180

    # 距離を計算するSQLの断片
    distance_sql = <<-SQL
      #{EARTH_RADIUS} * 2 * ASIN(SQRT(
        POWER(SIN((#{current_lat_rad} - RADIANS(latitude)) / 2), 2) +
        COS(#{current_lat_rad}) * COS(RADIANS(latitude)) *
        POWER(SIN((#{current_lng_rad} - RADIANS(longitude)) / 2), 2)
      ))
    SQL

    # geocode カラムから緯度と経度を抽出
    select("*,
           CAST(substring(geocode FROM '^(.*?),') AS DECIMAL(10,7)) as latitude,
           CAST(substring(geocode FROM ',(.*?)$') AS DECIMAL(10,7)) as longitude")
      .select(Arel.sql(distance_sql).as("distance")) # 距離を計算
      .where.not(geocode: nil) # geocode が nil のレコードを除外
      .order(Arel.sql("distance")) # 距離でソート
      .limit(limit) # 取得件数を制限
  end
end
