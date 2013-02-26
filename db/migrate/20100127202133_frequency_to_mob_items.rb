class FrequencyToMobItems < ActiveRecord::Migration

  def self.up
    add_column :mob_items, :frequency, :integer, {:default => 1}
  end

  def self.down
    remove_column :mob_items, :frequency
  end
end
