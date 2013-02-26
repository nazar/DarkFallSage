class CreateClubInvites < ActiveRecord::Migration
  def self.up
    create_table :clan_invites do |t|
      t.integer :clan_id, :inviter, :invitee
      t.integer :response, :default => 0
      t.string :token, :limit => 15
      t.datetime :actioned_at
      t.timestamps
    end
    add_index :clan_invites, :clan_id, {:name => 'club_invites_club'}
    add_index :clan_invites, :invitee, {:name => 'club_invites_invitee'}
    add_index :clan_invites, :inviter, {:name => 'club_invites_inviter'}
  end

  def self.down
    drop_table :clan_invites
  end
end
