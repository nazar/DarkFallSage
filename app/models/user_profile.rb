class UserProfile < ActiveRecord::Base

  belongs_to :user

  def self.gender_types
    { 0 => 'not saying',  1 => 'female', 2 => 'male'}
  end

  #caution when changing this list as it does have a skill dependency
  def self.game_races
    { 1 => 'Alfar', 2 => 'Dwarf', 3 => 'Human', 4 => 'Mahirim', 5 => 'Mirdain', 6 => 'Ork'}
  end

  #instance methods

  def gender_to_s
    UserProfile.gender_types[self.gender]
  end

  def race_to_s
    UserProfile.game_races[self.game_race]
  end

  def game_gender_to_s
    UserProfile.gender_types[self.game_gender]
  end
  
end
