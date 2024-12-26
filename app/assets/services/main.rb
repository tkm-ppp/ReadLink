require_relative '../services/kokkaitosyokan_api'

ndl_search = Kokkaitosyokanapi.new
books = ndl_search.get_book_info('オリジン', 'ダンブラウン')

books.each do |book|
  puts book
  puts "Cover URL: #{ndl_search.get_book_cover(book.isbn)}"
  puts '-----------'
end