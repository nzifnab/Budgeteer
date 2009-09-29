class AddNonDistributedFundsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :non_distributed_funds, :float
  end

  def self.down
    remove_column :users, :non_distributed_funds
  end
end
