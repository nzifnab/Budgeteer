class AddOverflowIntoIdToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :overflow_into_id, :integer
  end

  def self.down
    remove_column :accounts, :overflow_into_id
  end
end
