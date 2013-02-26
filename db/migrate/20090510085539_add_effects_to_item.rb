class AddEffectsToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :effects, :string, {:limit => 200}
  end

  def self.down
    remove_column :items, :effects
  end
end
