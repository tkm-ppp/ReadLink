require "net/http"
require "json"

class LibrariesController < ApplicationController
  def settings
    @user = current_user
    @libraries = Library.all
  end
  
  def update_library_settings
    current_user.library_ids = params[:library_ids]
    redirect_to settings_path, notice: "図書館設定を更新しました"
  end



  def show
    @library = Library.find_by(geocode: params[:geocode])
    @pref = extract_prefecture(@library.address)
    
    Rails.logger.debug("取得したパラメータ (geocode): #{@geocode}")
    Rails.logger.debug("表示するデータ: #{@library}")
  
    if @library.nil?
      flash.now[:alert] = "図書館情報が見つかりませんでした。geocode: #{@geocode}"
    end
  end


  def fetch_and_save_libraries
  endpoint = "https://api.calil.jp/library"
  params = {
    appkey: ENV["CALIL_API_KEY"],
    format: "json",
    limit: "100"
  }

  uri = URI(endpoint)
  uri.query = URI.encode_www_form(params)

  response = Net::HTTP.get_response(uri)
  response_body_utf8 = response.body.force_encoding("UTF-8")

  if response_body_utf8.start_with?("callback(") && response_body_utf8.end_with?(");")
    rjson = response_body_utf8.delete_prefix("callback(").delete_suffix(");")
  else
    rjson = response_body_utf8
  end

  begin
    libraries_data = JSON.parse(rjson)
    libraries_data.each do |library|
      Library.find_or_create_by(libkey: library["libkey"]) do |lib|
        lib.address = library["address"]
        lib.tel = library["tel"]
        lib.post = library["post"]
        lib.formal = library["formal"]
        lib.url_pc = library["url_pc"]
        lib.geocode = library["geocode"]
      end
    end
  rescue JSON::ParserError => e
    Rails.logger.error("JSONの解析エラー: #{e.message}")
  end
end

private

  PREFECTURES = %w[
    北海道 青森県 岩手県 宮城県 秋田県 山形県 福島県
    茨城県 栃木県 群馬県 埼玉県 千葉県 東京都 神奈川県
    新潟県 富山県 石川県 福井県 山梨県 長野県 岐阜県
    静岡県 愛知県 三重県 滋賀県 京都府 大阪府 兵庫県 奈良県 和歌山県
    鳥取県 島根県 岡山県 広島県 山口県 徳島県 香川県 愛媛県 高知県
    福岡県 佐賀県 長崎県 熊本県 大分県 宮崎県 鹿児島県 沖縄県
  ].freeze

  def extract_prefecture(address)
    PREFECTURES.detect { |pref| address.include?(pref) } || "不明"
  end

  def build_regions_data
    regions_data = {}
    # データベースから地域情報を取得
    Library.select(:region).distinct.each do |lib|
      regions_data[lib.region] ||= []
      regions_data[lib.region] << lib.prefecture
    end
    regions_data
  end
end
