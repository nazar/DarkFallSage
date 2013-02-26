class ItemsClipColumns < ActiveRecord::Migration
  def self.up
    #abilities
    add_column :abilities, :icon_file_name, :string, {:limit => 250}
    add_column :abilities, :icon_content_type, :string, {:limit => 20}
    add_column :abilities, :icon_file_size, :integer
    add_column :abilities, :icon_updated_at, :datetime
    #skills
    add_column :skills, :icon_file_name, :string, {:limit => 250}
    add_column :skills, :icon_content_type, :string, {:limit => 20}
    add_column :skills, :icon_file_size, :integer
    add_column :skills, :icon_updated_at, :datetime
    #items
    add_column :items, :icon_file_name, :string, {:limit => 250}
    add_column :items, :icon_content_type, :string, {:limit => 20}
    add_column :items, :icon_file_size, :integer
    add_column :items, :icon_updated_at, :datetime
  end

  def self.down
    remove_column :abilities, :icon_file_name
    remove_column :abilities, :icon_content_type
    remove_column :abilities, :icon_file_size
    remove_column :abilities, :icon_updated_at
    #skills
    remove_column :skills, :icon_file_name
    remove_column :skills, :icon_content_type
    remove_column :skills, :icon_file_size
    remove_column :skills, :icon_updated_at
    #items
    remove_column :items, :icon_file_name
    remove_column :items, :icon_content_type
    remove_column :items, :icon_file_size
    remove_column :skills, :icon_updated_at
  end
end
