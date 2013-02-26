class AddEmblemToClans < ActiveRecord::Migration
  def self.up
    add_column :clans, "crest_file_name",    :string, {:limit => 250}
    add_column :clans, "crest_content_type", :string, {:limit => 50}
    add_column :clans, "crest_file_size",    :integer
    add_column :clans, "crest_updated_at",   :datetime

  end

  def self.down
    remove_column :clans, "crest_file_name"
    remove_column :clans, "crest_content_type"
    remove_column :clans, "crest_file_size"
    remove_column :clans, "crest_updated_at"
  end
end
