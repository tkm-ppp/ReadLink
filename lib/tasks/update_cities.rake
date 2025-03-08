namespace :libraries do
  desc "Update cities for libraries in Hokkaido Prefecture, starting from the 311th record"
  task update_cities: :environment do
    total_count = Library.where("address LIKE ?", "%広島県%").count
    processed_count = 0
    start_from = 50

    Library.where("address LIKE ?", "%広島県%").order(:id).each_slice(10) do |batch|
      batch.each do |lib|
        begin
          processed_count += 1
    
          # ~個目まではスキップ
          next if processed_count <= start_from
    
          add = JapaneseAddressParser.call(lib.address)
          
          if add.nil? || add.city.nil?
            puts "Could not extract city for library ID #{lib.id} with address: #{lib.address}"
            next
          end
    
          exit_city = add.city.name
          lib.update!(city: exit_city)
    
          # 進捗を出力（10件ごとに表示）
          if processed_count % 10 == 0
            puts "Processed #{processed_count} libraries in Hokkaido out of #{total_count}."
          end
    
        rescue => e
          puts "Error processing library #{lib.id}: #{e.message}"
        end
      end
    end
    

    puts "City update process for Hokkaido completed. Total libraries processed: #{processed_count}/#{total_count}."
  end
end
