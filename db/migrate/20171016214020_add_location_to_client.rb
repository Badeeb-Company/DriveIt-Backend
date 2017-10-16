class AddLocationToClient < ActiveRecord::Migration[5.1]

  def up
  	add_column :users, :lat, :float
    add_column :users, :long, :float
    add_column :users, :address, :string
  end

  def down
  	remove_column :users, :lat
    remove_column :users, :long
    remove_column :users, :address
  end
end
