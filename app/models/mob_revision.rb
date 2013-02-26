class MobRevision < ActiveRecord::Base
  
  acts_as_revision

  belongs_to :user, :foreign_key => 'created_by'
  belongs_to :updater, :foreign_key => 'updated_by', :class_name => 'User'
  belongs_to :approver, :foreign_key => 'approved_by', :class_name => 'User'

  has_many :mob_items, :class_name => "MobItemRevision", :foreign_key => 'mob_id'

  has_many :items_drop, :through => :mob_items, :conditions => 'mob_items.mob_item_type = 1' , :source => :item, :select => 'items.*, mob_items.quantity, mob_items.frequency'
  has_many :items_skins,:through => :mob_items, :conditions => 'mob_items.mob_item_type = 2' , :source => :item, :select => 'items.*, mob_items.quantity, mob_items.frequency'
  has_many :items_sells,:through => :mob_items, :conditions => 'mob_items.mob_item_type = 3' , :source => :item, :select => 'items.*, mob_items.quantity'


  has_many :mob_spells, :class_name => "MobSpellRevision", :foreign_key => 'mob_id'
  has_many :spells_casts, :through => :mob_spells, :conditions => 'mob_spells.mob_spell_type = 1', :source => :spell, :select => 'spells.*, mob_spells.quantity'
  has_many :spells_sells, :through => :mob_spells, :conditions => 'mob_spells.mob_spell_type = 2', :source => :spell, :select => 'spells.*, mob_spells.quantity'

  has_friendly_id :name, :use_slug => true

  def mob_item_type_to_s
    Mob.mob_types[mob_type]
  end

  def difficulty_to_s
    Mob.mob_difficulties[difficulty]
  end
  
end
