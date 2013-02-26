class SkillRaceLimitedTo < ActiveRecord::Migration
  def self.up
    add_column :skills, :limited_to_race, :integer, {:default => 0}
  end

  def self.down
    remove_column :skills, :limited_to_race
  end
end
