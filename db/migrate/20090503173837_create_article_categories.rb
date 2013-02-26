class CreateArticleCategories < ActiveRecord::Migration
  def self.up
    create_table :article_categories do |t|
      t.integer :article_id, :category_id
      t.timestamps
    end
    add_index :article_categories, :article_id, {:name => :article_categories_article}
    add_index :article_categories, :category_id, {:name => :article_categories_category}
  end

  def self.down
    drop_table :article_categories
  end
end
