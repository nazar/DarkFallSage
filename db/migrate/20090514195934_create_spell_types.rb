class CreateSpellTypes < ActiveRecord::Migration
  def self.up
    create_table :spell_types do |t|
      t.string :name, :limit => 50
      t.text :description
      t.integer :created_by, :updated_by
      t.string :icon_file_name, :limit => 200
      t.string :icon_content_type, :limit => 20
      t.integer :icon_file_size
      t.datetime :icon_updated_at
      t.timestamps
    end
  end

  def self.down
    drop_table :spell_types
  end
end
