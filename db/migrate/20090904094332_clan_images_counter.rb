class ClanImagesCounter < ActiveRecord::Migration
  def self.up
    add_column :clans, :images_count, :integer, {:default => 0}
  end

  def self.down
    drop_column :clans, :images_count
  end
end
