class ImagesViewsCount < ActiveRecord::Migration

  def self.up
    add_column :images, :views_count, :integer, {:default => 0}
  end

  def self.down
    remove_column :images, :views_count
  end
end
