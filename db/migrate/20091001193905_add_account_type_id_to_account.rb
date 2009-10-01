class AddAccountTypeIdToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :account_type_id, :integer
  end

  def self.down
    remove_column :accounts, :account_type_id
  end
end
