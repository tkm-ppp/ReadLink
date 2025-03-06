namespace :libraries do
  task update_cities: :environment do
    Library.all.each do |lib|
      # 住所から市町村を抽出（例：空白区切りで2番目の要素を取得）
      add = JapaneseAddressParser.call(lib.address)
      exit_city = add.city.name
      lib.update(city: exit_city)
    end
  end
end
