class AllianceCleanup < ActiveRecord::Migration

  def self.up
    #remove un-needed columns
    remove_column :alliances, :conditions
    remove_column :alliances, :end_reason
    remove_column :alliances, :ended_at
    #new columns
    add_column :alliances, :clan_owner_id, :integer
    add_column :alliances, :clans_count, :integer, {:default => 1}
  end

  def self.down
    add_column :alliances, :conditions, :text
    add_column :alliances, :end_reason, :string, {:limit => 200}
    add_column :alliances, :ended_at, :datetime
    #
    remove_column :alliances, :clan_owner_id
    remove_column :alliances, :clans_count
  end
  
end
