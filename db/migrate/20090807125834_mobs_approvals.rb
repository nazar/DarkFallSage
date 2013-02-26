class MobsApprovals < ActiveRecord::Migration
  def self.up
    add_column :mobs, :approved_by, :integer
    add_column :mobs, :approved_at, :datetime
  end

  def self.down
    remove_column :mobs, :approved_by
    remove_column :mobs, :approved_at
  end
end
