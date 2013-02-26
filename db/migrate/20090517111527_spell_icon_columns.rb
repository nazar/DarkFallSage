class SpellIconColumns < ActiveRecord::Migration
  def self.up
    add_column :spells, :icon_file_name, :string, {:limit => 250}
    add_column :spells, :icon_content_type, :string, {:limit => 20}
    add_column :spells, :icon_file_size, :integer
    add_column :spells, :icon_updated_at, :datetime
  end

  def self.down
    remove_column :spells, :icon_file_name
    remove_column :spells, :icon_content_type
    remove_column :spells, :icon_file_size
    remove_column :spells, :icon_updated_at
  end
end
