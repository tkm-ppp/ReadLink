class AddLibidToLibraries < ActiveRecord::Migration[7.2]
  def change
    add_column :libraries, :libid, :string
  end
end
