class CreateComments < ActiveRecord::Migration
  
  def self.up
    create_table "comments", :force => true do |t|
      t.string   "title",            :limit => 50, :default => ""
      t.text     "body"
      t.datetime "created_at",                                        :null => false
      t.integer  "commentable_id",                 :default => 0,     :null => false
      t.string   "commentable_type", :limit => 15, :default => "",    :null => false
      t.integer  "user_id",                        :default => 0,     :null => false
      t.string   "ip",               :limit => 15
      t.string   "dns"
      t.boolean  "checked", 'spam',                :default => 0
      t.datetime "checked_at"
      t.integer  "checked_by"
      t.timestamps
    end
    add_index "comments", ["commentable_id"], :name => "commentable_id"
    add_index "comments", ["user_id"], :name => "user_id"
    add_index "comments", ["ip"], :name => "ip"
  end

  def self.down
    drop_table :comments
  end
end
