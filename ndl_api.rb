require 'net/http'
require 'json'

# 既存のコード...

def fetch_data_from_ndl_api(query)
  uri = URI("https://api.ndl.go.jp/...") # 実際のAPIエンドポイントを使用
  params = { q: query, ... } # 必要なパラメータを設定
  uri.query = URI.encode_www_form(params)

  response = Net::HTTP.get(uri)
  data = JSON.parse(response)

  # ここでPublisher情報を抽出
  data['items'].each do |item|
    title = item['title']
    publisher = item['publisher'] # Publisher情報を取得
    puts "Title: #{title}, Publisher: #{publisher}" # Publisher情報を表示
  end
end

# 既存のコード... 