class AddTags < ActiveRecord::Migration
  def self.up

    create_table "taggings", :force => true do |t|
      t.integer "tag_id"
      t.integer "taggable_id"
      t.string  "taggable_type"
      t.integer "created_by"
    end
    add_index "taggings", ["tag_id", "taggable_id", "taggable_type"], :name => "taggings_tag_id_index"
    add_index "taggings", ["taggable_id"], :name => "index_taggings_on_taggable_id"
    add_index "taggings", ["created_by"], :name => "index_taggings_on_created_by"

    create_table "tags", :force => true do |t|
      t.string  "name"
      t.integer "taggings_count", :default => 0
    end
    add_index "tags", ["name"], :name => "tags_name_index"

  end

  def self.down
    drop_table :taggings
    drop_table :tags
  end
end
