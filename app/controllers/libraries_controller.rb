require "net/http"
require "json"

class LibrariesController < ApplicationController
  def show
    @geocode = params[:geocode] # geocode パラメータを取得
    @library_detail = fetch_library_detail(@geocode) # geocode を渡す

    Rails.logger.debug("取得したパラメータ (geocode): #{@geocode}")
    Rails.logger.debug("表示するデータ: #{@library_detail}")

    if @library_detail.nil?
      flash.now[:alert] = "図書館情報が見つかりませんでした。geocode: #{@geocode}" # geocode をログに出力
    end
  end

  def fetch_library_detail(geocode)
    endpoint = "https://api.calil.jp/library"
    params = {
      appkey: ENV["CALIL_API_KEY"],
      geocode: geocode,
      limit: 1,
      format: "json"
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
      Rails.logger.debug("JSON解析結果: #{libraries_data}")
      if libraries_data.is_a?(Array) && libraries_data.any?
        libraries_data.first # 詳細情報は配列の最初の要素に入っているから
      else
        nil
      end
    rescue JSON::ParserError => e
      Rails.logger.error("JSONの解析エラー: #{e.message} - geocode: #{geocode}")
      nil
    end
  end
end
