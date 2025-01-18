class CsvViewerController < ApplicationController
  def index
    @csv_data = NdlApi.read_from_csv('search_results.csv')
  end
end 