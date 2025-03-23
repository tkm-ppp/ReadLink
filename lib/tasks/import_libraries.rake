require 'csv'
require 'rake'

namespace :import do
  desc "Import libraries from CSV file"
  task libraries: :environment do
    csv_file = Rails.root.join('public', 'libraries_across_Japan.csv') # 絶対パスの指定

    begin
      CSV.foreach(csv_file, headers: true) do |row|
        Library.create!(row.to_hash) # row.to_hashを使って全てのカラムを一度に渡す
      end
    rescue ActiveRecord::RecordInvalid => e
      puts "Error importing libraries: #{e.message}"
    rescue CSV::MalformedCSVError => e
      puts "Malformed CSV error: #{e.message}"
    rescue StandardError => e
      puts "An error occurred: #{e.message}"
    end

    puts "Libraries imported successfully!"
  end
end
