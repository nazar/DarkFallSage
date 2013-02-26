class UserReputation < ActiveRecord::Migration

  def self.up
    add_column :user_counters, :reputation, :integer, {:default => 10}
    ActiveRecord::Base.connection.execute('update user_counters set reputation=10')
  end

  def self.down
    remove_column :user_counters, :reputation 
  end
end
