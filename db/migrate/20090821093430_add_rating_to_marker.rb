class AddRatingToMarker < ActiveRecord::Migration
  def self.up
    add_column :markers, :rating, :integer, {:default => 0}
    #set to defaults
    ActiveRecord::Base.connection.execute('update markers set rating=0')
  end

  def self.down
    remove_column :markers, :rating
  end
end
