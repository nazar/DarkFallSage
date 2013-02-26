class CountForAllUsers < ActiveRecord::Migration
  def self.up
    User.all.each do |user|
      user.initialise_counter_if_required
    end
  end

  def self.down
  end
end
