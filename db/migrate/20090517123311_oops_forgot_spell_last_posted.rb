class OopsForgotSpellLastPosted < ActiveRecord::Migration
  def self.up
    add_column :spells, :last_posted, :datetime
  end

  def self.down
    remove_column :spells, :last_posted
  end
end
