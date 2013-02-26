class CreateSkills < ActiveRecord::Migration
  def self.up
    create_table :skills do |t|
      t.string :name, :limit => 100
      t.text :description
      t.integer :skill_type, :skill_sub_type
      t.integer :added_by, :updated_by
      t.timestamps
    end
  end

  def self.down
    drop_table :skills
  end
end
