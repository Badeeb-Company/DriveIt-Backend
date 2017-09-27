class DriverOnline < ActiveRecord::Migration[5.1]
  def change
  	add_column :drivers, :driver_availability, :integer, :default => 0
  	remove_column :drivers, :invited, :boolean
  end
end
