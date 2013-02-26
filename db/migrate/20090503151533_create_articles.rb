class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table "articles", :force => true do |t|
      t.column "user_id",             :integer
      t.column "title",               :string,   :limit => 200
      t.column 'body',                :text
      t.column "reads_count",         :integer,                 :default => 0
      t.column "comments_count",      :integer,                 :default => 0
      t.column "up_count",            :integer,                 :default => 0
      t.column "down_count",          :integer,                 :default => 0
      t.column "bookmarks_count",     :integer,                 :default => 0
      t.column "active",              :boolean,                 :default => false
      t.column "approved",            :boolean,                 :default => false
      t.column "approved_date",       :datetime
      t.column "approved_by",         :integer
      t.column "commentable",         :boolean,                 :default => true
      t.column "rateable",            :boolean,                 :default => true
      t.column "bookmarkable",        :boolean,                 :default => true
      t.timestamps
    end
    add_index :articles, :user_id
  end

  def self.down
    drop_table :articles
  end
end
