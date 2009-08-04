class CreateAccountHistories < ActiveRecord::Migration
  def self.up
    create_table :account_histories do |t|
      t.integer :account_id
      t.float :amount
      t.text :description
      t.integer :income_id

      t.timestamps
    end
  end

  def self.down
    drop_table :account_histories
  end
end
