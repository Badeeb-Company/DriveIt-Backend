class CreateTripDrivers < ActiveRecord::Migration[5.1]
  def change
    create_table :trip_drivers do |t|
      t.references :trip
      t.references :driver
      t.float :distance
      t.float :time
      t.timestamps
    end
    add_column :trips, :index, :integer, :default => 0
  end
end
