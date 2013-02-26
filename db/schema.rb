# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100314200743) do

  create_table "abilities", :force => true do |t|
    t.string   "name",              :limit => 20
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "required_count",                   :default => 0
    t.string   "icon_file_name",    :limit => 250
    t.string   "icon_content_type", :limit => 20
    t.integer  "icon_file_size"
    t.datetime "icon_updated_at"
    t.datetime "last_posted"
    t.integer  "posts_count",                      :default => 0
    t.integer  "topics_count",                     :default => 0
  end

  create_table "alliance_clans", :force => true do |t|
    t.integer  "alliance_id"
    t.integer  "clan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status",                    :default => 0
    t.string   "token",       :limit => 15
  end

  add_index "alliance_clans", ["alliance_id"], :name => "alliance_clans_alliance"
  add_index "alliance_clans", ["clan_id"], :name => "alliance_clans_clan"
  add_index "alliance_clans", ["token"], :name => "index_alliance_clans_on_token"

  create_table "alliance_logs", :force => true do |t|
    t.integer  "alliance_id"
    t.integer  "clan_id"
    t.string   "log",         :limit => 200
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "alliances", :force => true do |t|
    t.string   "name",          :limit => 100
    t.integer  "ended_by"
    t.text     "treaty"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "clans_count",                  :default => 1
    t.integer  "clan_owner_id"
  end

  create_table "article_categories", :force => true do |t|
    t.integer  "article_id"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "article_categories", ["article_id"], :name => "article_categories_article"
  add_index "article_categories", ["category_id"], :name => "article_categories_category"

  create_table "articles", :force => true do |t|
    t.integer  "user_id"
    t.string   "title",           :limit => 200
    t.text     "body"
    t.integer  "reads_count",                    :default => 0
    t.integer  "comments_count",                 :default => 0
    t.integer  "up_count",                       :default => 0
    t.integer  "down_count",                     :default => 0
    t.integer  "bookmarks_count",                :default => 0
    t.boolean  "active",                         :default => false
    t.boolean  "approved",                       :default => false
    t.datetime "approved_date"
    t.integer  "approved_by"
    t.boolean  "commentable",                    :default => true
    t.boolean  "rateable",                       :default => true
    t.boolean  "bookmarkable",                   :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "articles", ["user_id"], :name => "index_articles_on_user_id"

  create_table "blocks", :force => true do |t|
    t.integer  "block_type",                      :default => 0
    t.integer  "dynamic_block"
    t.integer  "position"
    t.integer  "placement",                       :default => 1
    t.integer  "placement_option",                :default => 0
    t.string   "title"
    t.text     "content"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "cache_until"
    t.boolean  "cached",                          :default => false
    t.text     "cached_content"
    t.string   "block_class",      :limit => 200
    t.string   "refresh_rate",     :limit => 50
  end

  create_table "categories", :force => true do |t|
    t.string   "type",        :limit => 20
    t.string   "category",    :limit => 50
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "item_counts",               :default => 0
  end

  add_index "categories", ["parent_id"], :name => "index_categories_on_parent_id"

  create_table "clan_applications", :force => true do |t|
    t.integer  "user_id"
    t.integer  "clan_id"
    t.integer  "actioned_by"
    t.integer  "status",                         :default => 0
    t.datetime "actioned_at"
    t.string   "actioned_reason", :limit => 200
    t.text     "application"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "clan_applications", ["user_id"], :name => "clan_applications_user"
  add_index "clan_applications", ["clan_id"], :name => "clan_applications_clan"
  add_index "clan_applications", ["actioned_by"], :name => "clan_applications_actioner"

  create_table "clan_forums", :force => true do |t|
    t.integer  "clan_id"
    t.integer  "access_type"
    t.string   "name",          :limit => 100
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "topics_count",                 :default => 0
    t.integer  "posts_count",                  :default => 0
    t.text     "description"
    t.datetime "last_posted"
    t.integer  "required_rank",                :default => 0
  end

  create_table "clan_invites", :force => true do |t|
    t.integer  "clan_id"
    t.integer  "inviter"
    t.integer  "invitee"
    t.integer  "response",                  :default => 0
    t.string   "token",       :limit => 15
    t.datetime "actioned_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "clan_invites", ["clan_id"], :name => "club_invites_club"
  add_index "clan_invites", ["invitee"], :name => "club_invites_invitee"
  add_index "clan_invites", ["inviter"], :name => "club_invites_inviter"
  add_index "clan_invites", ["token"], :name => "index_clan_invites_on_token"

  create_table "clan_members", :force => true do |t|
    t.integer  "clan_id"
    t.integer  "user_id"
    t.integer  "approved_by"
    t.integer  "rank"
    t.datetime "approved_at"
    t.string   "reject_reason", :limit => 200
    t.string   "application",   :limit => 200
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "clan_members", ["clan_id"], :name => "index_clan_members_on_clan_id"
  add_index "clan_members", ["user_id"], :name => "index_clan_members_on_user_id"

  create_table "clans", :force => true do |t|
    t.integer  "owner_id"
    t.integer  "access_type"
    t.integer  "server"
    t.string   "name",               :limit => 100
    t.text     "description"
    t.text     "charter"
    t.integer  "members_count",                     :default => 0
    t.integer  "forums_count",                      :default => 0
    t.integer  "topics_count",                      :default => 0
    t.integer  "posts_count",                       :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "crest_file_name",    :limit => 250
    t.string   "crest_content_type", :limit => 50
    t.integer  "crest_file_size"
    t.datetime "crest_updated_at"
    t.integer  "images_count",                      :default => 0
  end

  add_index "clans", ["owner_id"], :name => "index_clans_on_owner_id"

  create_table "comments", :force => true do |t|
    t.string   "title",            :limit => 50, :default => ""
    t.text     "body"
    t.datetime "created_at"
    t.integer  "commentable_id",                 :default => 0,     :null => false
    t.string   "commentable_type", :limit => 15, :default => "",    :null => false
    t.integer  "user_id",                        :default => 0,     :null => false
    t.string   "ip",               :limit => 15
    t.string   "dns"
    t.boolean  "checked",                        :default => false
    t.boolean  "spam",                           :default => false
    t.datetime "checked_at"
    t.integer  "checked_by"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id"], :name => "commentable_id"
  add_index "comments", ["user_id"], :name => "user_id"
  add_index "comments", ["ip"], :name => "ip"

  create_table "forums", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "topics_count", :default => 0
    t.integer  "posts_count",  :default => 0
    t.integer  "position"
    t.datetime "last_posted"
    t.integer  "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "forums", ["created_by"], :name => "index_forums_on_created_by"

  create_table "images", :force => true do |t|
    t.string   "imageable_type",       :limit => 30
    t.integer  "imageable_id"
    t.integer  "user_id"
    t.string   "title",                :limit => 100
    t.text     "description"
    t.string   "picture_file_name",    :limit => 254
    t.string   "picture_content_type", :limit => 30
    t.integer  "picture_file_size"
    t.datetime "picture_updated_at"
    t.integer  "posts_count",                         :default => 0
    t.integer  "topics_count",                        :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "views_count",                         :default => 0
  end

  add_index "images", ["imageable_id"], :name => "index_images_on_imageable_id"

  create_table "items", :force => true do |t|
    t.boolean  "craftable",                           :default => false
    t.integer  "item_type"
    t.integer  "item_sub_type"
    t.integer  "added_by"
    t.integer  "updated_by"
    t.integer  "weapon_skill"
    t.integer  "weapon_rank"
    t.float    "protect_acid"
    t.float    "protect_arrow"
    t.float    "protect_bludge"
    t.float    "protect_cold"
    t.float    "protect_fire"
    t.float    "protect_light"
    t.float    "protect_pierce"
    t.float    "protect_slash"
    t.float    "weight"
    t.float    "weapon_attack_mult"
    t.float    "weapon_basic_damage"
    t.float    "durability_max"
    t.float    "durability"
    t.float    "quality"
    t.float    "npc_cost"
    t.float    "encumbrance"
    t.string   "name",                 :limit => 200
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "effects",              :limit => 200
    t.float    "attack_speed"
    t.float    "protect_holy"
    t.float    "protect_impact"
    t.float    "protect_unholy"
    t.float    "restore_health"
    t.float    "restore_mana"
    t.integer  "required_count",                      :default => 0
    t.string   "icon_file_name",       :limit => 250
    t.string   "icon_content_type",    :limit => 20
    t.integer  "icon_file_size"
    t.datetime "icon_updated_at"
    t.datetime "last_posted"
    t.integer  "posts_count",                         :default => 0
    t.integer  "topics_count",                        :default => 0
    t.string   "image_file_name",      :limit => 250
    t.string   "image_content_type",   :limit => 20
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.float    "nourishment_duration"
    t.integer  "images_count",                        :default => 0
    t.integer  "markers_count",                       :default => 0
    t.float    "protect_mental"
    t.float    "protect_arcane"
    t.float    "protect_malediction"
  end

  create_table "markers", :force => true do |t|
    t.integer  "markable_id",                                                 :default => 0, :null => false
    t.string   "markable_type", :limit => 50
    t.integer  "user_id"
    t.string   "title",         :limit => 100
    t.decimal  "lng",                          :precision => 11, :scale => 8
    t.decimal  "lat",                          :precision => 11, :scale => 8
    t.decimal  "xm",                           :precision => 11, :scale => 8
    t.decimal  "xs",                           :precision => 11, :scale => 8
    t.string   "xd",            :limit => 1
    t.decimal  "ym",                           :precision => 11, :scale => 8
    t.decimal  "ys",                           :precision => 11, :scale => 8
    t.string   "yd",            :limit => 1
    t.integer  "level"
    t.datetime "created_at"
    t.integer  "rating",                                                      :default => 0
  end

  add_index "markers", ["markable_id", "markable_type"], :name => "index_markers_on_markable_id_and_markable_type"
  add_index "markers", ["user_id"], :name => "index_markers_on_user_id"
  add_index "markers", ["lng"], :name => "index_markers_on_long"
  add_index "markers", ["lat"], :name => "index_markers_on_lat"

  create_table "mob_items", :force => true do |t|
    t.integer  "mob_id"
    t.integer  "item_id"
    t.integer  "mob_item_type"
    t.float    "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "revisable_original_id"
    t.integer  "revisable_branched_from_id"
    t.integer  "revisable_number"
    t.string   "revisable_name"
    t.string   "revisable_type"
    t.datetime "revisable_current_at"
    t.datetime "revisable_revised_at"
    t.datetime "revisable_deleted_at"
    t.boolean  "revisable_is_current"
    t.integer  "frequency",                  :default => 1
  end

  add_index "mob_items", ["mob_id"], :name => "index_mob_items_on_mob_id"
  add_index "mob_items", ["item_id"], :name => "index_mob_items_on_item_id"

  create_table "mob_spells", :force => true do |t|
    t.integer  "mob_id"
    t.integer  "spell_id"
    t.integer  "mob_spell_type"
    t.float    "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "revisable_original_id"
    t.integer  "revisable_branched_from_id"
    t.integer  "revisable_number"
    t.string   "revisable_name"
    t.string   "revisable_type"
    t.datetime "revisable_current_at"
    t.datetime "revisable_revised_at"
    t.datetime "revisable_deleted_at"
    t.boolean  "revisable_is_current"
  end

  add_index "mob_spells", ["mob_id"], :name => "index_mob_spells_on_mob_id"
  add_index "mob_spells", ["spell_id"], :name => "index_mob_spells_on_spell_id"

  create_table "mob_weaknesses", :force => true do |t|
    t.integer  "mob_id"
    t.integer  "weakness_type"
    t.integer  "weakness_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mob_weaknesses", ["mob_id"], :name => "index_mob_weaknesses_on_mob_id"

  create_table "mobs", :force => true do |t|
    t.integer  "mob_type"
    t.integer  "difficulty"
    t.integer  "hp"
    t.string   "name",                       :limit => 100
    t.text     "description"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "images_count",                              :default => 0
    t.integer  "markers_count",                             :default => 0
    t.integer  "topics_count",                              :default => 0
    t.integer  "posts_count",                               :default => 0
    t.integer  "items_count",                               :default => 0
    t.integer  "spells_count",                              :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "revisable_original_id"
    t.integer  "revisable_branched_from_id"
    t.integer  "revisable_number"
    t.string   "revisable_name"
    t.string   "revisable_type"
    t.datetime "revisable_current_at"
    t.datetime "revisable_revised_at"
    t.datetime "revisable_deleted_at"
    t.boolean  "revisable_is_current"
    t.integer  "approved_by"
    t.datetime "approved_at"
    t.string   "melee_weakness",             :limit => 150
    t.string   "spell_weakness",             :limit => 150
  end

  create_table "moderators", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "can_forums"
    t.boolean  "can_db"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "moderators", ["user_id"], :name => "index_moderators_on_user_id"

  create_table "news", :force => true do |t|
    t.integer  "user_id",                      :default => 0,     :null => false
    t.string   "title",                        :default => "",    :null => false
    t.text     "body",                                            :null => false
    t.datetime "expire_date"
    t.integer  "reads_count",                  :default => 0
    t.boolean  "expire_item",                  :default => false
    t.boolean  "active",                       :default => false
    t.boolean  "commentable",                  :default => false
    t.integer  "comments_count",               :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",           :limit => 20
  end

  add_index "news", ["user_id"], :name => "index_news_on_user_id"

  create_table "news_categories", :force => true do |t|
    t.integer  "news_id"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "news_categories", ["news_id"], :name => "index_news_categories_on_news_id"
  add_index "news_categories", ["category_id"], :name => "index_news_categories_on_category_id"

  create_table "pois", :force => true do |t|
    t.string   "name",                       :limit => 100
    t.text     "description"
    t.integer  "added_by"
    t.integer  "updated_by"
    t.integer  "poi_type"
    t.integer  "markers_count",                             :default => 0
    t.integer  "posts_count",                               :default => 0
    t.integer  "topics_count",                              :default => 0
    t.integer  "images_count",                              :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "revisable_original_id"
    t.integer  "revisable_branched_from_id"
    t.integer  "revisable_number"
    t.string   "revisable_name"
    t.string   "revisable_type"
    t.datetime "revisable_current_at"
    t.datetime "revisable_revised_at"
    t.datetime "revisable_deleted_at"
    t.boolean  "revisable_is_current"
    t.string   "approved_by"
    t.datetime "approved_at"
  end

  create_table "posts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "topic_id"
    t.integer  "reply_id"
    t.text     "body"
    t.string   "ip",         :limit => 20
    t.string   "title",      :limit => 200
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rating",                    :default => 0
  end

  add_index "posts", ["user_id"], :name => "index_posts_on_user_id"
  add_index "posts", ["topic_id", "created_at"], :name => "index_posts_on_forum_id"

  create_table "prereqs", :force => true do |t|
    t.string   "prereqable_type", :limit => 20
    t.integer  "prereqable_id"
    t.string   "need_type",       :limit => 20
    t.integer  "need_id"
    t.float    "qty"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "prereqs", ["prereqable_id"], :name => "prereqable_id"
  add_index "prereqs", ["need_id"], :name => "index_prereqs_on_prereq_id"
  add_index "prereqs", ["need_id"], :name => "index_prereqs_on_need_id"

  create_table "reputations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "reputation",                :default => 0
    t.integer  "total",                     :default => 0
    t.integer  "updated_by"
    t.string   "reason",     :limit => 200
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reputations", ["user_id"], :name => "index_reputations_on_user_id"

  create_table "skills", :force => true do |t|
    t.string   "name",              :limit => 100
    t.text     "description"
    t.integer  "skill_type"
    t.integer  "skill_sub_type"
    t.integer  "added_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "required_count",                   :default => 0
    t.string   "icon_file_name",    :limit => 250
    t.string   "icon_content_type", :limit => 20
    t.integer  "icon_file_size"
    t.datetime "icon_updated_at"
    t.datetime "last_posted"
    t.integer  "posts_count",                      :default => 0
    t.integer  "topics_count",                     :default => 0
    t.integer  "limited_to_race",                  :default => 0
    t.boolean  "magic_school",                     :default => false
    t.integer  "images_count",                     :default => 0
    t.float    "gold"
  end

  create_table "slugs", :force => true do |t|
    t.string   "name"
    t.integer  "sluggable_id"
    t.integer  "sequence",                     :default => 1, :null => false
    t.string   "sluggable_type", :limit => 40
    t.string   "scope",          :limit => 40
    t.datetime "created_at"
  end

  add_index "slugs", ["name", "sluggable_type", "scope", "sequence"], :name => "index_slugs_on_name_and_sluggable_type_and_scope_and_sequence", :unique => true
  add_index "slugs", ["sluggable_id"], :name => "index_slugs_on_sluggable_id"

  create_table "spell_reagents", :force => true do |t|
    t.integer  "item_id"
    t.integer  "spell_id"
    t.integer  "added_by"
    t.float    "qty"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "spell_reagents", ["item_id"], :name => "spell_reagents_item"
  add_index "spell_reagents", ["spell_id"], :name => "spell_reagents_spell"

  create_table "spells", :force => true do |t|
    t.string   "name",              :limit => 20
    t.text     "description"
    t.integer  "spell_type"
    t.integer  "spell_target"
    t.float    "mana"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "icon_file_name",    :limit => 250
    t.string   "icon_content_type", :limit => 20
    t.integer  "icon_file_size"
    t.datetime "icon_updated_at"
    t.integer  "required_count",                   :default => 0
    t.integer  "level"
    t.integer  "added_by"
    t.integer  "updated_by"
    t.float    "cool_down"
    t.float    "time_to_cast"
    t.integer  "topics_count",                     :default => 0
    t.integer  "posts_count",                      :default => 0
    t.datetime "last_posted"
    t.integer  "school_id"
    t.integer  "images_count",                     :default => 0
    t.float    "gold"
    t.integer  "sub_type"
  end

  add_index "spells", ["school_id"], :name => "index_spells_on_school_id"

  create_table "taggings", :force => true do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.string  "taggable_type"
    t.integer "created_by"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type"], :name => "taggings_tag_id_index"
  add_index "taggings", ["taggable_id"], :name => "index_taggings_on_taggable_id"
  add_index "taggings", ["created_by"], :name => "index_taggings_on_created_by"

  create_table "tags", :force => true do |t|
    t.string  "name"
    t.integer "taggings_count", :default => 0
  end

  add_index "tags", ["name"], :name => "tags_name_index"

  create_table "topics", :force => true do |t|
    t.integer  "topicable_id"
    t.string   "topicable_type"
    t.integer  "user_id"
    t.string   "title",          :limit => 200
    t.integer  "hits",                          :default => 0
    t.string   "sticky",                        :default => "0"
    t.integer  "posts_count",                   :default => 0
    t.datetime "replied_at"
    t.string   "locked",                        :default => "0"
    t.integer  "replied_by"
    t.integer  "last_post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "topics", ["topicable_id"], :name => "index_topics_topicable_id"
  add_index "topics", ["user_id"], :name => "index_topics_on_user_id"
  add_index "topics", ["replied_at"], :name => "index_topics_on_replied_at"

  create_table "user_counters", :force => true do |t|
    t.integer  "user_id"
    t.integer  "posts_count",        :default => 0
    t.integer  "blogs_count",        :default => 0
    t.integer  "comments_count",     :default => 0
    t.integer  "friends_count",      :default => 0
    t.integer  "favourites_count",   :default => 0
    t.integer  "clubs_count",        :default => 0
    t.integer  "profile_view_count", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "reputation",         :default => 0
  end

  add_index "user_counters", ["user_id"], :name => "index_user_counters_on_user_id"

  create_table "user_profiles", :force => true do |t|
    t.integer  "user_id"
    t.string   "state",             :limit => 50
    t.string   "country",           :limit => 50
    t.integer  "rank"
    t.text     "bio"
    t.integer  "gender",                          :default => 0
    t.datetime "birth_day"
    t.string   "aim",               :limit => 20
    t.string   "yahoo",             :limit => 20
    t.string   "msn",               :limit => 20
    t.string   "game_city",         :limit => 50
    t.string   "game_nick",         :limit => 20
    t.integer  "game_race"
    t.string   "game_clan",         :limit => 50
    t.integer  "game_gender"
    t.string   "pc_processor",      :limit => 20
    t.string   "pc_ram",            :limit => 20
    t.string   "pc_video_card",     :limit => 20
    t.string   "pc_video_driver_v", :limit => 20
    t.string   "pc_disk_space",     :limit => 20
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_profiles", ["user_id"], :name => "index_user_profiles_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "name",                       :limit => 50
    t.string   "email"
    t.string   "avatar"
    t.string   "avatar_type",                :limit => 50
    t.integer  "rank"
    t.string   "crypted_password",           :limit => 40
    t.string   "salt",                       :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_seen_at"
    t.datetime "remember_token_expires_at"
    t.string   "remember_token"
    t.string   "token",                      :limit => 10
    t.boolean  "admin",                                    :default => false
    t.boolean  "activated",                                :default => false
    t.boolean  "active",                                   :default => false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type",        :limit => 20
    t.integer  "avatar_file_size"
    t.string   "profile_image_file_name"
    t.string   "profile_image_content_type", :limit => 20
    t.integer  "profile_image_file_size"
    t.datetime "profile_image_updated_at"
    t.datetime "avatar_updated_at"
  end

  add_index "users", ["login"], :name => "login"
  add_index "users", ["token"], :name => "users_token_index"

  create_table "votes", :force => true do |t|
    t.boolean  "vote",          :default => false
    t.integer  "voteable_id",                      :null => false
    t.string   "voteable_type",                    :null => false
    t.integer  "voter_id"
    t.string   "voter_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["voter_id", "voter_type", "voteable_id", "voteable_type"], :name => "uniq_one_vote_only", :unique => true
  add_index "votes", ["voter_id", "voter_type"], :name => "fk_voters"
  add_index "votes", ["voteable_id", "voteable_type"], :name => "fk_voteables"

end
