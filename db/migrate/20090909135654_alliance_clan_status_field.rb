class AllianceClanStatusField < ActiveRecord::Migration

  def self.up
    add_column :alliance_clans, :status, :integer, {:default => 0}
    add_column :alliance_clans, :token,  :string,  {:limit => 15}
  end

  def self.down
    remove_column :alliance_clans, :status
    remove_column :alliance_clans, :token
  end
end
