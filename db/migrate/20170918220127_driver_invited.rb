class DriverInvited < ActiveRecord::Migration[5.1]
  def change
  	add_column :drivers, :invited, :boolean, :default => false
  end
end
