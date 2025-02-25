# app/services/library_importer.rb
require "net/http"
require "json"
require "csv"

class LibraryImporter
    PREFECTURES = %w[
        北海道 青森県 岩手県 宮城県 秋田県 山形県 福島県
        茨城県 栃木県 群馬県 埼玉県 千葉県 東京都 神奈川県
        新潟県 富山県 石川県 福井県 山梨県 長野県 岐阜県
        静岡県 愛知県 三重県 滋賀県 京都府 大阪府 兵庫県 奈良県 和歌山県
        鳥取県 島根県 岡山県 広島県 山口県 徳島県 香川県 愛媛県 高知県
        福岡県 佐賀県 長崎県 熊本県 大分県 宮崎県 鹿児島県 沖縄県
    ].freeze # 都道府県名の配列

    # APIリクエストのリトライ回数
    MAX_RETRIES = 3
    # APIリクエストの間隔（秒）
    API_REQUEST_INTERVAL = 1

  def self.import_all_libraries
    PREFECTURES.each do |pref|
      import_libraries(pref)
    end
  end

  def self.import_multiple_libraries(prefectures)
    prefectures.each do |pref|
      import_libraries(pref)
    end
  end

  def self.import_libraries(prefecture)
    endpoint = "https://api.calil.jp/library"
    limit = 5000 # 1回のリクエストで取得する件数
    offset = 0# 取得開始位置

    loop do
      params = {
        appkey: ENV["CALIL_API_KEY"],
        pref: prefecture,
        format: "json",
        limit: limit,
        offset: offset
      }

      uri = URI(endpoint)
      uri.query = URI.encode_www_form(params)
      response = Net::HTTP.get_response(uri)
      response_body_utf8 = response.body.force_encoding("UTF-8")

      # JSONP形式の場合の処理
      rjson = if response_body_utf8.start_with?("callback(") && response_body_utf8.end_with?(");")
                 response_body_utf8.delete_prefix("callback(").delete_suffix(");")
      else
                response_body_utf8
      end

      begin
        libraries_data = JSON.parse(rjson)

        if libraries_data.empty?
          puts "#{prefecture}: データの取得が完了"
          break # データが空になったらループを抜ける
        end

        library_data_array = []

        libraries_data.each do |library|
          begin
            Library.find_or_create_by!(libid: library["libid"]) do |lib|
              lib.address = library["address"]
              lib.tel = library["tel"]
              lib.post = library["post"]
              lib.formal = library["formal"]
              lib.url_pc = library["url_pc"]
              lib.geocode = library["geocode"]
              lib.libkey = library["libkey"]
              lib.libid = library["libid"]
              puts "Creating or updating library: #{library["formal"]} in #{prefecture}"
            end
          rescue ActiveRecord::RecordInvalid => e
            Rails.logger.error("レコードの保存に失敗: #{e.message} - #{library}")
          rescue => e
            Rails.logger.error("ライブラリデータの処理中にエラーが発生: #{e.message} - #{library}")
          end
        end

        offset += limit
      rescue JSON::ParserError => e
        Rails.logger.error("JSONの解析エラー: #{e.message} - 県: #{prefecture}")
        break # エラーが発生したらループを抜ける
      rescue => e
        Rails.logger.error("APIリクエスト中に予期せぬエラーが発生: #{e.message} - 県: #{prefecture}")
        break # エラーが発生したらループを抜ける
      end

      sleep API_REQUEST_INTERVAL  # APIリクエストの間隔を空ける
    end
  end

  def self.export_libraries_to_csv(filepath = Rails.root.join("db", "libraries.csv"))
    kyoto_libraries = Library.where("address LIKE ?", "%豊中市%")

    CSV.open(filepath, "wb") do |csv|
      csv << Library.column_names # ヘッダー行を追加
      kyoto_libraries.find_each do |library|
      # Library.all.find_each do |library|
        csv << library.attributes.values
      end
    end
  end
end
