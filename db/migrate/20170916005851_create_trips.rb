class CreateTrips < ActiveRecord::Migration[5.1]
  def change
    create_table :trips do |t|
      t.integer :user_id, :null => false
      t.integer :driver_id
      t.integer :trip_state
      t.text :destination, :null => false
      t.float :long, :null => false
      t.float :lat, :null => false	
      t.timestamps
    end
    add_index :trips, :user_id
    add_index :trips, :driver_id
  end
end
