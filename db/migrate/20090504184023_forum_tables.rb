class ForumTables < ActiveRecord::Migration
  def self.up

    create_table "forums", :force => true do |t|
      t.string   "name"
      t.text     "description"
      t.integer  "topics_count", :default => 0
      t.integer  "posts_count",  :default => 0
      t.integer  "position"
      t.datetime "last_posted"
      t.integer  "created_by"
      t.timestamps
    end
    add_index "forums", ["created_by"], :name => "index_forums_on_created_by"

    create_table "topics", :force => true do |t|
      t.integer  "topicable_id"
      t.string   "topicable_type", :length => 50
      t.integer  "user_id"
      t.string   "title",          :limit => 200
      t.integer  "hits",         :default => 0
      t.integer  "sticky",       :default => 0
      t.integer  "posts_count",  :default => 0
      t.datetime "replied_at"
      t.boolean  "locked",       :default => false
      t.integer  "replied_by"
      t.integer  "last_post_id"
      t.timestamps
    end
    add_index "topics", ["topicable_id"], :name => "index_topics_topicable_id"
    add_index "topics", ["user_id"]
    add_index "topics", ["replied_at"]

    create_table "posts", :force => true do |t|
      t.integer  "user_id", "topic_id", 'reply_id'
      t.text     "body"
      t.string   "ip",  :limit => 20
      t.string   "title",      :limit => 200
      t.timestamps
    end

    add_index "posts", ["user_id"], :name => "index_posts_on_user_id"
    add_index "posts", ["topic_id", "created_at"], :name => "index_posts_on_forum_id"
  end

  def self.down
    drop_table :forums
    drop_table :topics
    drop_table :posts
  end
end
