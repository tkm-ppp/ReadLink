# app/services/library_importer.rb
require 'net/http'
require 'json'

class LibraryImporter
  def self.import_libraries(prefecture)
    endpoint = "https://api.calil.jp/library"
    params = {
      appkey: ENV["CALIL_API_KEY"],
      pref: prefecture,
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
      Rails.logger.error("JSONの解析エラー: #{e.message} - 県: #{prefecture}")
    end
  end
end
