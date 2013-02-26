class CreateNews < ActiveRecord::Migration

  def self.up
    #main news table
    create_table "news", :force => true do |t|
      t.integer  "user_id",        :default => 0,     :null => false
      t.string   "title",          :default => "",    :null => false
      t.text     "body",                              :null => false
      t.datetime "expire_date"
      t.integer  "reads_count",    :default => 0
      t.boolean  "expire_item",    :default => false
      t.boolean  "active",         :default => false
      t.boolean  "commentable",    :default => false
      t.integer  "comments_count", :default => 0
      t.timestamps
      t.string   "type", :limit => 20
    end
    add_index :news, :user_id

    #create news category join table
    create_table 'news_categories' do |t|
      t.integer :news_id, :category_id
      t.timestamps
    end
    add_index :news_categories, :news_id
    add_index :news_categories, :category_id
  end

  def self.down
    drop_table :news
    drop_table :news_categories
  end
  
end
