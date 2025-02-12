require "net/http"
require "json"
require "rails" # Rails.logger を使用するため

class LibraryFetcher
  CARIL_API_URL = "https://api.calil.jp/check"
  OPENBD_API_URL = "https://api.openbd.jp/v1/get"

  def self.fetch_book_detail_from_openbd(isbn)
    uri = URI("#{OPENBD_API_URL}?isbn=#{isbn}")

    begin
      response = Net::HTTP.get_response(uri)

      unless response.is_a?(Net::HTTPSuccess)
        return nil # エラー時は nil を返す
      end

      json_response = response.body
      books_data = JSON.parse(json_response)

      book_info = books_data.first # 配列の最初の要素を取得 (通常は1件のはず)
      return nil if book_info.nil? # 書籍情報が nil の場合は nil を返す

      detail = book_info["summary"] || {} # summary が nil の場合を考慮
      cover_url = book_info["cover"]

      book = {
        title: detail["title"],
        author: detail["author"],
        publisher: detail["publisher"],
        isbn: detail["isbn"],
        cover_url: cover_url,
        pubdate: detail["pubdate"], # 出版日
        series: detail["series"], # シリーズ名
        volume: detail["volume"], # 巻数
        biographical_note: book_info["onix"]&.dig("DescriptiveDetail", "Contributor")&.first&.[]("BiographicalNote"), # 著者略歴 (最初の著者のみ)
        text_contents: book_info["onix"]&.dig("CollateralDetail", "TextContent"), # 内容紹介 (配列)
        price_amount: book_info["onix"]&.dig("ProductSupply", "SupplyDetail", "Price")&.first&.[]("PriceAmount"), # 価格 (最初の価格情報のみ)
        sub_genre: book_info["hanmoto"]&.[]("sub_genre"), # サブジャンル
        reviews: book_info["reviews"] # 書評情報 (配列)
      }

      # 書評情報を整形
      if book[:reviews].present?
        book[:reviews] = book[:reviews].map do |review|
          {
            body: review["body"],
            source: review["source"],
            date: review["date"],
            link: review["link"]
          }
        end
      end

      book

    rescue JSON::ParserError => json_error
      Rails.logger.error "OpenBD JSON Parse Error: #{json_error.message}"
      Rails.logger.error "Failed JSON Response Body: #{json_response}"
      nil

    rescue => e
      Rails.logger.error "Error fetching book detail from OpenBD for ISBN #{isbn}: #{e.message}"
      nil
    end
  end



    def self.fetch_book_details(isbn)
      appkey = ENV["CALIL_API_KEY"]
      prefecture_system_ids = [
        "Osaka_Osaka", "Osaka_Sakai", "Osaka_Kishiwada", "Osaka_Toyonaka",
        "Osaka_Ikeda", "Osaka_Suita", "Osaka_IzumiOtsu", "Osaka_Takatsuki",
        "Osaka_Kaizuka", "Osaka_Moriguchi", "Osaka_Hirakata", "Osaka_Ibaraki",
        "Osaka_Yao", "Osaka_IzumiSano", "Osaka_Tondabayashi", "Osaka_Neyagawa",
        "Osaka_Kawachinagano", "Osaka_Matsubara", "Osaka_Daito", "Osaka_Izumi",
        "Osaka_Minoh", "Osaka_Kashiwara", "Osaka_Habikino", "Osaka_Kadoma",
        "Osaka_Setsuto", "Osaka_Takaishi", "Osaka_Fujidera", "Osaka_Higashiosaka",
        "Osaka_Sennan", "Osaka_Shirodawate", "Osaka_Katano", "Osaka_Osakasayama",
        "Osaka_Hannan", "Osaka_Shimamoto", "Osaka_Toyono", "Osaka_Nose",
        "Osaka_Tadaoka", "Osaka_Kumatori", "Osaka_Tajiri", "Osaka_Misaki",
        "Osaka_Taishi", "Osaka_Kawachinagano", "Osaka_Chihayaakasaka"
      ]

      params = {
        appkey: appkey,
        isbn: isbn,
        systemid: prefecture_system_ids.join(","),
        format: "json"
      }

      uri = URI(CARIL_API_URL)
      uri.query = URI.encode_www_form(params)

      Rails.logger.debug "Request URL: #{uri}"

      session = nil

      loop do
        begin
          response = Net::HTTP.get_response(uri)

          Rails.logger.debug "Response Class: #{response.class}"

          unless response.is_a?(Net::HTTPResponse)
            Rails.logger.error "Unexpected response type: #{response.class}"
            Rails.logger.error "Response Body (possibly error message): #{response.body}" if response.respond_to?(:body)
            return { error: "APIリクエストで予期せぬレスポンスを受け取りました" }
          end

          Rails.logger.debug "Response Status Code: #{response.code}"

          unless response.is_a?(Net::HTTPSuccess)
            Rails.logger.error "HTTP Error Response: #{response.code} #{response.message}"
            Rails.logger.error "Response Body: #{response.body}"
            return { error: "APIリクエストエラー: HTTPステータスコード #{response.code}" }
          end

          json_response = response.body
          Rails.logger.debug "Response Body (JSONP before conversion): #{json_response}" # JSONP形式のレスポンスをログ出力

          # JSONP形式からJSON形式に変換 (callback() が付いている場合)
          if json_response.start_with?("callback(") && json_response.end_with?(");")
            json_response = json_response.delete_prefix("callback(").delete_suffix(");")
          end

          result = JSON.parse(json_response)
          Rails.logger.debug "Parsed JSON Result: #{result.inspect}" # パース後のJSON結果をログ出力

          if result["continue"] == 1
            session = result["session"] # セッションIDを取得
            sleep 1 # 1秒待機 (APIの推奨に従う)
            # 2回目以降のリクエストは session ID を付与
            params_with_session = {
              appkey: appkey,
              session: session,
              format: "json"
            }
            uri.query = URI.encode_www_form(params_with_session) # URIを更新
            next # ループを継続
          else
            return format_availability_results(result) # 結果を整形して返す
          end

        rescue JSON::ParserError => json_error
          Rails.logger.error "JSON Parse Error: #{json_error.message}" # JSONパースエラーをログ出力
          return { error: "レスポンスのJSONパースに失敗しました" } # JSONパースエラーの情報を返す

        rescue => e
          Rails.logger.error "Error checking availability for ISBN #{isbn}: #{e.message}" # その他のエラーをログ出力
          return { error: "在庫状況の確認に失敗しました: #{e.message}" } # エラー情報を返す
        end
      end
    end

    def self.format_availability_results(result) # 結果を整形するメソッド
      formatted_results = {} # 返却するハッシュ

      if result["books"] && result["books"].key?(result["books"].keys.first)
        isbn = result["books"].keys.first # ISBNを取得
        library_info = result["books"][isbn]
        formatted_results[isbn] = {}

        library_info.each do |systemid, details| # systemid のループ
          formatted_results[isbn][systemid] = { # systemid をキーにする
            status: details["status"],
            reserveurl: details["reserveurl"],
            libraries: {} # libraries をハッシュで初期化
          }
          if details["libkey"]
            details["libkey"].each do |lib_name, status|
              formatted_results[isbn][systemid][:libraries][lib_name] = status # 図書館名をキー、状態を値
            end
          end
        end
      else
        formatted_results = { error: "書籍情報が見つかりませんでした。" }
      end

      Rails.logger.debug "Formatted Results: #{formatted_results.inspect}" # 整形後の結果をログ出力
      formatted_results
    end
end
