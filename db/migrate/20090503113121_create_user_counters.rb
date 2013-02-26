class CreateUserCounters < ActiveRecord::Migration
  
  def self.up
    create_table "user_counters", :force => true do |t|
      t.column "user_id",            :integer
      t.column "posts_count",        :integer, :default => 0
      t.column "blogs_count",        :integer, :default => 0
      t.column "comments_count",     :integer, :default => 0
      t.column "friends_count",      :integer, :default => 0
      t.column "favourites_count",   :integer, :default => 0
      t.column "clubs_count",        :integer, :default => 0
      t.column "profile_view_count", :integer, :default => 0
      t.timestamps
    end
    add_index "user_counters", ["user_id"], :name => "index_user_counters_on_user_id"
    
  end

  def self.down
    drop_table :user_counters
  end
end
