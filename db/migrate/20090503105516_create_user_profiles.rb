class CreateUserProfiles < ActiveRecord::Migration
  def self.up
    create_table "user_profiles" do |t|
      t.column "user_id",       :integer
      t.column "state",         :string,   :limit => 50
      t.column "country",       :string,   :limit => 50
      t.column "rank",          :integer
      t.column "bio",           :text
      t.column "gender",        :integer,                :default => 0
      t.column "birth_day",     :datetime
      t.column "aim",           :string,   :limit => 20
      t.column "yahoo",         :string,   :limit => 20
      t.column "msn",           :string,   :limit => 20
      t.column "game_city",     :string,   :limit => 50
      t.column "game_nick",     :string,   :limit => 20
      t.column "game_race",     :integer
      t.column "game_clan",     :string,   :limit => 50
      t.column "game_gender",   :integer
      t.column "pc_processor",  :string,   :limit => 20
      t.column "pc_ram",        :string,   :limit => 20
      t.column "pc_video_card", :string,   :limit => 20
      t.column "pc_video_driver_v",       :string,   :limit => 20
      t.column "pc_disk_space", :string,   :limit => 20
      t.timestamps
    end
    add_index "user_profiles", ["user_id"], :name => "index_user_profiles_on_user_id"
  end

  def self.down
    drop_table :user_profiles
  end
end
