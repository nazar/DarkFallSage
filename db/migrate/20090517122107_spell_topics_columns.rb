class SpellTopicsColumns < ActiveRecord::Migration
  def self.up
    add_column :spells, :topics_count, :integer, {:default => 0}
    add_column :spells, :posts_count, :integer, {:default => 0}
  end

  def self.down
    remove_column :spells, :topics_count
    remove_column :spells, :posts_count
  end
end
