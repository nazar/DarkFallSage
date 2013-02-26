class PoiApproval < ActiveRecord::Migration
  def self.up
    add_column :pois, :approved_by, :string
    add_column :pois, :approved_at, :datetime
  end

  def self.down
    remove_column :pois, :approved_by
    remove_column :pois, :approved_at
  end
end
