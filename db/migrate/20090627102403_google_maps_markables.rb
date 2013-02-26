class GoogleMapsMarkables < ActiveRecord::Migration
  def self.up

    create_table "markers" do |t|
      t.integer  "markable_id",   :default => 0, :null => false
      t.string   "markable_type", :limit => 50
      t.integer  "user_id"
      t.string   "title",         :limit => 100
      t.decimal  "long",                         :precision => 11, :scale => 8
      t.decimal  "lat",                          :precision => 11, :scale => 8
      t.decimal  "xm",                           :precision => 11, :scale => 8
      t.decimal  "xs",                           :precision => 11, :scale => 8
      t.string   'xd', :limit => 1
      t.decimal  "ym",                           :precision => 11, :scale => 8
      t.decimal  "ys",                           :precision => 11, :scale => 8
      t.string   'yd', :limit => 1
      t.integer  "level"
      t.datetime "created_at"
    end

    add_index "markers", ["markable_id", "markable_type"], :name => "index_markers_on_markable_id_and_markable_type"
    add_index "markers", ["user_id"], :name => "index_markers_on_user_id"
    add_index "markers", ["long"], :name => "index_markers_on_long"
    add_index "markers", ["lat"], :name => "index_markers_on_lat"

  end

  def self.down
    drop_table 'markers'
  end
end
