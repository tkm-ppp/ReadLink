require 'csv'
require_relative 'config/environment'

CSV.open('libraries.csv', 'w') do |csv|
  # ヘッダー行を追加
  csv << %w[id formal url_pc address tel post geocode libkey libid systemid city created_at updated_at]

  # データを追加
  Library.find_each do |library|
    csv << [
      library.id,
      library.formal,
      library.url_pc,
      library.address,
      library.tel,
      library.post,
      library.geocode,
      library.libkey,
      library.libid,
      library.systemid,
      library.city,
      library.created_at,
      library.updated_at
    ]
  end
end

puts "CSVファイルが正常に作成されました: libraries.csv"
