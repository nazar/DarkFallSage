class BlockSimpleCaching < ActiveRecord::Migration

  def self.up
    add_column :blocks, :cache_until, :datetime
    add_column :blocks, :cached, :boolean, {:default => false}
    add_column :blocks, :cached_content, :text
    add_column :blocks, :block_class, :string, {:limit => 200}
    add_column :blocks, :refresh_rate, :string, {:limit => 50}
    #set all current to cached
    Block.update_all('cached = 1')
  end

  def self.down
    remove_column :blocks, :cache_until
    remove_column :blocks, :cached
    remove_column :blocks, :cached_content
    remove_column :blocks, :block_class
    remove_column :blocks, :refresh_rate
  end
end
