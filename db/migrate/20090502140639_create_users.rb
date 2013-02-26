class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true do |t|
      t.string   "login"
      t.string   "name",                      :limit => 50
      t.string   "email"
      t.string   "avatar"
      t.string   "avatar_type",               :limit => 50
      t.integer  "rank"
      t.string   "crypted_password",          :limit => 40
      t.string   "salt",                      :limit => 40
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "last_seen_at"
      t.datetime "remember_token_expires_at"
      t.string   "remember_token"
      t.string   "token",                     :limit => 10
      t.boolean  "admin",                                    :default => false
      t.boolean  "activated",                                :default => false
      t.boolean  "active",                                   :default => false
    end
    add_index "users", ["login"], :name => "login"
    add_index "users", ["token"], :name => "users_token_index"
  end

  def self.down
    drop_table :users
  end
end
