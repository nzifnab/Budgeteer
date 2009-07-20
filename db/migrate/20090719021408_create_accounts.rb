class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.string :name
      t.integer :priority
      t.float :add_per_month
      t.boolean :add_per_month_as_percent
      t.float :cap
      t.integer :prerequisite_id
      t.float :amount
      t.boolean :enabled

      t.timestamps
    end
  end

  def self.down
    drop_table :accounts
  end
end
