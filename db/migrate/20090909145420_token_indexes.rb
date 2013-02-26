class TokenIndexes < ActiveRecord::Migration

  def self.up
    add_index :alliance_clans, :token
    add_index :clan_invites, :token
  end

  def self.down
    remove_index :alliance_clans, :token
    remove_index :clan_invites, :token
  end
  
end
