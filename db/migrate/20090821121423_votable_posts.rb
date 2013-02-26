class VotablePosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :rating, :integer, {:default => 0}
    #set to defaults
    ActiveRecord::Base.connection.execute('update posts set rating=0')
  end

  def self.down
    remove_column :posts, :rating
  end
end
