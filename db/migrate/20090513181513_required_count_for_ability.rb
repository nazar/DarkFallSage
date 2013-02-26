class RequiredCountForAbility < ActiveRecord::Migration
  def self.up
    add_column :abilities, :required_count, :integer, {:default => 0}
  end

  def self.down
    remove_column :abilities, :required_count
  end
end
