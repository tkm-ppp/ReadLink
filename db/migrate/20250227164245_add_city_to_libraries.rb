class AddCityToLibraries < ActiveRecord::Migration[7.2]
  def change
    add_column :libraries, :city, :string
  end
end
