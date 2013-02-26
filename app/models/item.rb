class Item < ActiveRecord::Base

  has_many :prereqs, :as => :prereqable
  has_many :needed_by, :as => :need, :class_name => 'Prereq'

  has_many :spell_reagents
  has_many :spells, :through => :spell_reagents, :source => :spell

  has_many :mob_items
  has_many :sellers, :through => :mob_items, :source => :mob, :conditions => 'mobs.mob_type = 2', :select => 'mobs.*, mob_items.quantity'
  has_many :droppers, :through => :mob_items, :source => :mob, :conditions => 'mobs.mob_type = 1', :select => 'mobs.*, mob_items.quantity, mob_items.frequency'

  has_many :images, :as => :imageable

  validates_presence_of :name, :item_type, :weight
  validates_uniqueness_of :name

  named_scope :reagents, :conditions => {:item_type => 5, :item_sub_type => 2}, :order => 'name'
  named_scope :by_item_type, lambda{|item_type|
    {:conditions => {:item_type => item_type.to_i}}
  }
  named_scope :by_item_type_and_sub, lambda{|item_type, item_sub|
    {:conditions => {:item_type => item_type.to_i, :item_sub_type => item_sub.to_i}}
  }
  #block helper finders
  named_scope :latest_items_created, lambda{|limit| limit ||= 5
    {:order => 'created_at DESC', :limit => limit, :include => :slugs}
  }
  named_scope :latest_items_updated,  lambda{|limit| limit ||= 5
    {:order => 'updated_at DESC', :limit => limit, :include => :slugs}
  }

  named_scope :reagents_for_spell, lambda{|spell|
    {:select => 'items.*, spell_reagents.qty',
     :joins => 'inner join spell_reagents on items.id = spell_reagents.item_id',
     :conditions => ['spell_reagents.spell_id = ?', spell.id]}
  }

  named_scope :items_for_skill, lambda{|skill|
    {:select => 'items.*, prereqs.qty',
     :joins => 'inner join prereqs on prereqs.prereqable_id = items.id',
     :conditions => ['prereqs.need_id = ? and prereqs.need_type = ? and prereqs.prereqable_type = ?', skill.id, 'Skill', 'Item']
    }
  }

  named_scope :required_by_item, lambda{ |item|
    {:select => 'items.*, prereqs.qty',
     :joins => 'inner join prereqs on prereqs.prereqable_id = items.id',
     :conditions => ['prereqs.need_id = ? and prereqs.need_type = ? and prereqs.prereqable_type = ?', item.id, 'Item', 'Item']
    }
  }

  

  has_attached_file :icon,
                    :styles => { :original => ['32x32#', "jpg"]  },
                    :default_style => :original,
                    :default_url => "/images/missing.png",
                    :convert_options => { :all => "-strip" }

  has_attached_file :image,
                    :styles => { :original => ['128x128#', "jpg"]  },
                    :default_style => :original,
                    :default_url => "/images/noimage_item.png",
                    :convert_options => { :all => "-strip" }

  has_friendly_id :name, :use_slug => true

  acts_as_markable :class => 'DfMarker'

  acts_as_forumable

  ItemObject     = 1
  ItemWeapon     = 2
  ItemArmour     = 3
  ItemTool       = 4
  ItemAlchemy    = 5
  ItemPotion     = 6
  ItemFood       = 7
  ItemShield     = 8
  ItemHouse      = 9
  ItemEnchanting = 10
  ItemBloodcraft = 11
  ItemShadecraft = 12

  #class methods

  #hardcode item types... append new types
  def self.item_types
    {Item::ItemObject => 'object', Item::ItemWeapon => 'weapon', Item::ItemArmour => 'armour', Item::ItemTool => 'tool',
     Item::ItemAlchemy => 'alchemy', Item::ItemPotion => 'potion', Item::ItemFood => 'food', Item::ItemShield => 'shield',
     Item::ItemHouse => 'house', Item::ItemEnchanting => 'enchanting', Item::ItemBloodcraft => 'bloodcraft', Item::ItemShadecraft => 'shadecraft'}
  end

  def self.item_types_for_select
    Item.item_types.sort{|a,b|a[1]<=>b[1]}.collect{|i|[i.last, i.first]}
  end

  #hardcode item subtypes... append new subtypes
  #returns all subtypes hash if blank args... else return subtype for specified type id
  def self.item_sub_types(type = nil)
    types = {
#      1 => { 1 => 'none' }, #object
      Item::ItemWeapon => { 1 => 'axe',        2 => 'sword', 3 => 'dagger', 4 => 'ranged', 5 => 'great axe',
             7 => 'two handed sword', 8 => 'club', 9 => 'great club',
             10 => 'polearm', 11 => 'staff', 12 => 'sithras'}, #weapon
      Item::ItemArmour  => { 1 => 'leather',    2 => 'chain', 3 => 'plate', 4 => 'dragon armour', 5 => 'full plate',
             6 => 'scale', 7 => 'banded', 8 => 'cloth', 9 => 'shirt', 10 => 'infernal', 11 => 'bone',
             12 => 'robe', 13 => 'studded', 14 => 'non craftable', 15 => 'padded', 16 => 'rings',  17 => 'necklaces'    },     #armour
      Item::ItemTool => { 1 => 'crafting', 2 => 'attachable'},                                     #tools
      Item::ItemAlchemy => { 2 => 'reagent' },                             #alchemy
      Item::ItemPotion => { 1 => 'health',     2 => 'mana', 3 => 'stamina', 4 => 'cure' },                                #potions
      Item::ItemHouse => { 1=> 'deeds', 2 => 'furniture', 3 => 'trophies'},
      Item::ItemEnchanting =>{ 1=> 'blood', 2=> 'heart', 3=> 'eye', 4=> 'bone', 5=> 'quartz', 6=> 'leaf', 7=> 'catalyst', 8=> 'bile',
             9 => 'claw', 10 => 'cinder', 11 => 'corpseflesh', 12=> 'darktaint', 13=> 'horn', 14=> 'hoarfrost',
             15=> 'lifeforce', 16=> 'quintessence', 17=> 'sparkstone', 18=> 'stormrune', 19=> 'shadowcrest',
             20=> 'tooth', 21 => 'venom sack'},
      Item::ItemBloodcraft =>{1 => 'banded', 2=> 'chain', 3=> 'dragon', 4 => 'full plate', 5=> 'infernal', 6=> 'plate', 7=> 'scale'},
      Item::ItemShadecraft =>{1=> 'bone', 2=> 'cloth', 3=> 'leather', 4=> 'padded', 5=> 'studded'}
    }
    unless type.nil?
      types[type]
    else
      types
    end
  end

  def self.all_items_by_type_as_hash(options = {})
    items = Item.find :all, options
    result = {}
    items.each do |item|
      result[item.item_type] = result[item.item_type].nil? ? [item] : result[item.item_type] << [item]  
    end
    result
  end

  def self.is_armour?(type)
    (type == Item::ItemArmour) || (type == Item::ItemBloodcraft) || (type == Item::ItemShadecraft)
  end

  #instance methods

  def item_type_to_s
    Item.item_types[item_type].capitalize
  end

  def item_subtype_to_s
    unless Item.item_sub_types[item_type].blank? or Item.item_sub_types[item_type][item_sub_type].blank?
      Item.item_sub_types[item_type][item_sub_type].capitalize
    else
      ''
    end
  end

  def icon_path
    Darkfall.extract_icon_path('/assets/items/icons/', id, icon_file_name)
  end

  #this override the friendly_id plugin to_param to utilise the SlugCache... redo once on Rails 2.3+
  def slug(reload = false)
    @most_recent_slug = nil if reload
    @most_recent_slug ||= SlugCache.query_cache(self.class.base_class, id)
    @most_recent_slug ||= slugs.first
  end
  


end
