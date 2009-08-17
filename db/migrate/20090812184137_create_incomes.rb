class CreateIncomes < ActiveRecord::Migration
  def self.up
    create_table :incomes do |t|
      t.float :amount
      t.text :description
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :incomes
  end
end
