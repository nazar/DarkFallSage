class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.column :type, :string, :limit => 20
      t.column :category, :string, :limit => 50
      t.integer :parent_id
      t.timestamps
    end
#    add_index :categories, :categorisable_id, {:name => :categories_id}
    add_index :categories, :parent_id
  end

  def self.down
    drop_table :categories
  end
end
