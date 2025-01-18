require 'rexml/document'
require 'uri'
require 'net/http'
require 'json'
require 'open-uri'
require 'libxml'

# 文字列としてのURL
base_url = "https://ndlsearch.ndl.go.jp/api/opensearch"

# URIオブジェクトへ変換
uri = URI(base_url)

# query
all_params = ["お疲れ", "地球", "ひいては", "宇宙の皆様"]
all_params.each_with_index do |i, x|
  params = { title:"#{i}" }
  # ハッシュをエンコード(urlに変換)
  uri.query = URI.encode_www_form(params)
    # Net::HTTPでAPIリクエストを送信する
    response = Net::HTTP.get(uri)
    # puts response
    doc_parsed = LibXML::XML::Document.string(response)
    doc_parsed.find('/rss/channel/item').each do |x|
    @titles = x.find('title').first&.content
    @authors =  x.find('author').first&.content
    end
  # root_attributes = doc_parsed.find('/rss/channel/item')
  # root_attributes.each do |key, value|
  #   puts "Attribute: #{key}, Value: #{value}"
  # end
end
# doc = REXML::Document.new(response)

# p doc

