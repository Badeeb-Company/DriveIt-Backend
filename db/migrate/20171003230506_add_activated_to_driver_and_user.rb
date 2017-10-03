class AddActivatedToDriverAndUser < ActiveRecord::Migration[5.1]
  def up
    add_column :drivers, :activated, :boolean, default: :false
    add_column :users, :activated, :boolean, default: :false
  end

  def down
  	remove_column :drivers, :activated
    remove_column :users, :activated
  end
end
