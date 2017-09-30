class DriverType < ActiveRecord::Migration[5.1]
  def change
  	add_column :drivers, :driver_type, :integer, :default => 0
  end
end
