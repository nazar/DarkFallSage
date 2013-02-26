class SkillMagicSchoolFlag < ActiveRecord::Migration

  def self.up
    add_column :skills, :magic_school, :boolean, {:default => false}
  end

  def self.down
    remove_column :skills, :magic_school
  end
end
