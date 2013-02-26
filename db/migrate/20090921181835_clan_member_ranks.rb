class ClanMemberRanks < ActiveRecord::Migration

  def self.up
    add_column :clan_forums, :required_rank, :integer, {:default => 0}
  end

  def self.down
    remove_column :clan_forums, :required_rank
  end
end
