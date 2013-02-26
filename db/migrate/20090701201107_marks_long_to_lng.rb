class MarksLongToLng < ActiveRecord::Migration
  def self.up
    rename_column :markers, :long, :lng
  end

  def self.down
    rename_column :markers, :lng, :long
  end
end
