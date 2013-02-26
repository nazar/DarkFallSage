class Mob < ActiveRecord::Base

  belongs_to :user, :foreign_key => 'created_by'
  belongs_to :updater, :foreign_key => 'updated_by', :class_name => 'User'
  belongs_to :approver, :foreign_key => 'approved_by', :class_name => 'User'

  has_many :mob_items, :dependent => :destroy
  
  has_many :items_drop, :through => :mob_items, :conditions => 'mob_items.mob_item_type = 1 and mob_items.revisable_is_current = 1' , :source => :item, :select => 'items.*, mob_items.quantity, mob_items.frequency'
  has_many :items_skins,:through => :mob_items, :conditions => 'mob_items.mob_item_type = 2 and mob_items.revisable_is_current = 1' , :source => :item, :select => 'items.*, mob_items.quantity, mob_items.frequency'
  has_many :items_sells,:through => :mob_items, :conditions => 'mob_items.mob_item_type = 3 and mob_items.revisable_is_current = 1' , :source => :item, :select => 'items.*, mob_items.quantity'

  has_many :mob_spells, :dependent => :destroy
  has_many :spells_casts, :through => :mob_spells, :conditions => 'mob_spells.mob_spell_type = 1 and mob_spells.revisable_is_current = 1',
           :source => :spell, :select => 'spells.*, mob_spells.quantity'
  has_many :spells_sells, :through => :mob_spells, :conditions => 'mob_spells.mob_spell_type = 2 and mob_spells.revisable_is_current = 1',
           :source => :spell, :select => 'spells.*, mob_spells.quantity'

  has_many :images, :as => :imageable

  has_many :mob_weaknesses

                                                                                                                                                                                                
  validates_presence_of :name
  validates_uniqueness_of :name

  acts_as_forumable

  acts_as_markable :class => 'DfMarker'

  acts_as_revisable do
    except :updated_by, :images_count, :markers_count, :topics_count, :posts_count, :items_count, :spells_count, :approved_by, :approved_at
  end

  before_revise :clear_approvals_if_not_admins!
  after_revise :revise_mob_items!
  after_revert :revert_mob_items!

  has_friendly_id :name, :use_slug => true

  MobTypeMob = 1
  MobTypeNPC = 2

  named_scope :unapproved, :conditions => ['(approved_by is null and updated_by <> 2)']

  named_scope :latest, lambda{|*limit| limit = limit[0].nil? ? nil : limit[0]
    {:order => 'created_at desc', :limit => limit}
  }

  named_scope :recent, lambda{|*limit| limit = limit[0].nil? ? nil : limit[0]
    {:order => 'updated_at desc', :limit => limit}
  }

  #class methods

  def self.mob_types
    {Mob::MobTypeMob => 'mob', Mob::MobTypeNPC => 'npc'}
  end

  def self.mob_difficulties
    {1 => 'easy', 2 => 'moderate', 3 => 'hard', 4 => 'hellish', 5 => 'Chuck Norris'}
  end

  def self.mob_difficulties_for_select
    Mob.mob_difficulties.sort{|a,b|a[0]<=>b[0]}.collect{|i|["#{i.first} - #{i.last}", i.first]}
  end

  def self.mob_types_for_select
    Mob.mob_types.sort{|a,b|a[1]<=>b[1]}.collect{|i|[i.last, i.first]}
  end

  def self.last_approved(mob)
    Mob.without_model_scope do
      Mob.find(:all, :conditions => ['((revisable_original_id = ?) or (id = ?)) and approved_by is not null', mob.id, mob.id],
               :order => 'approved_at DESC', :limit => 1).first
    end
  end

  def self.mob_alphabet
    Mob.find(:all, :select => 'ucase(left(name, 1)) a, count(id) c', :group => 'left(name, 1)').inject({}) do |out, mob|
      out.merge(mob.a => mob.c)
    end
  end

  def self.re_cache_all_mob_weaknesses
    Mob.transaction do
      Mob.all.each do |m|
        spells =  m.mob_weaknesses.spell_weakness.inject({}){|keys, weakness| keys.merge(weakness.weakness_id => weakness.id)}
        melees =  m.mob_weaknesses.melee_weakness.inject({}){|keys, weakness| keys.merge(weakness.weakness_id => weakness.id)}
        m.cache_spell_and_melee_weakness(spells, melees)
        m.save
      end
    end  
  end

  #instance methods

  def mob_item_type_to_s
    Mob.mob_types[mob_type]
  end

  def difficulty_to_s
    Mob.mob_difficulties[difficulty]
  end

  def added_by
    created_by
  end

  def caster_to_f
    spells_count > 0 ? 'Yes' : 'No' if mob_type == Mob::MobTypeMob
  end

  #this override the friendly_id plugin to_param to utilise the SlugCache... redo once on Rails 2.3+
  def slug(reload = false)
    @most_recent_slug = nil if reload
    @most_recent_slug ||= SlugCache.query_cache(self.class.base_class, id)
    @most_recent_slug ||= slugs.first
  end

  def cache_spell_and_melee_weakness(spell_keys, melee_keys)
    self.spell_weakness = MobWeakness.weaknesses_to_cache(MobWeakness::WeaknessSpell, spell_keys)
    self.melee_weakness = MobWeakness.weaknesses_to_cache(MobWeakness::WeaknessMelee, melee_keys)
  end

  private

  def clear_approvals_if_not_admins!
    if !is_reverting?
      if !Moderator.db_moderator?(updater) 
        self.approved_by = nil
        self.approved_at = nil
      end
    end  
  end

  def revise_mob_items!
    if !is_reverting?
      self.mob_items.each(&:revise!)
      self.mob_spells.each(&:revise!)
    end  
  end

  def revert_mob_items!
    if is_reverting?
      self.mob_items.each{ |item| item.revert_or_relink_first_revision(self)}
      self.mob_spells.each{|item| item.revert_or_relink_first_revision(self)}
    end
  end




end
