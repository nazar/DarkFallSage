class Spell < ActiveRecord::Base

  has_many :prereqs, :as => :prereqable
  has_many :needed_by, :as => :need, :class_name => 'Prereq'

  has_many :spell_reagents
  has_many :reagents, :through => :spell_reagents, :source => :item

  has_many :mob_spells
  has_many :sellers, :through => :mob_spells, :source => :mob, :conditions => 'mobs.mob_type = 2'

  has_many :images, :as => :imageable

  has_many :topics, :as => :topicable, :order => 'sticky desc, replied_at desc', :dependent => :destroy, :include => :user do
    def first
      @first_topic ||= find(:first)
    end
  end

  has_many :posts, :through => :topics, :order => 'posts.created_at desc', :include => :user do
    def last
      @last_post ||= find(:first, :include => :user)
    end
  end

  belongs_to :school, :foreign_key => 'school_id', :class_name => 'Skill'

  validates_presence_of :name
  validates_uniqueness_of :name

  #constants

  SubTypeCold        = 1
  SubTypeFire        = 2
  SubTypeLightning   = 3
  SubTypeAcid        = 4
  SubTypeHoly        = 5
  SubTypeUnholy      = 6
  SubTypeArcane      = 7
  SubTypeImpact      = 8
  SubTypeInfliction  = 9
  SubTypeMalediction = 10
  SubTypeMental      = 11

  named_scope :spells_by_effect, lambda{|effect|
    {:conditions => {:spell_type => effect.to_i}}
  }
  #block helper finders
  named_scope :latest_spells_updated, lambda{|limit| limit ||= 5
    {:order => 'updated_at DESC', :limit => limit, :include => :slugs}
  }
  named_scope :latest_spells_created, lambda{|limit| limit ||= 5
    {:order => 'created_at DESC', :limit => limit, :include => :slugs}
  }

  named_scope :spells_using_reagent, lambda{ |item|
    {:select => 'spells.*, spell_reagents.qty',
     :joins => 'inner join spell_reagents on spells.id = spell_reagents.spell_id',
     :conditions => ['spell_reagents.item_id = ?', item.id]}
  }

  named_scope :required_by_item, lambda{ |item|
    {:select => 'spells.*, prereqs.qty',
     :joins => 'inner join prereqs on prereqs.prereqable_id = spells.id',
     :conditions => ['prereqs.need_id = ? and prereqs.need_type = ? and prereqs.prereqable_type = ?', item.id, 'Item', 'Spell']
    }
  }


  has_attached_file :icon,
                    :styles => {:original => ['32x32#', "jpg"] },
                    :default_style => :original,
                    :default_url => "/images/missing.png",
                    :convert_options => { :all => "-strip" }

  has_friendly_id :name, :use_slug => true 


  #class methods

  def self.spell_types
    {1 => 'damage', 2 => 'buff', 3 => 'debuff', 4 => 'DOT', 5 => 'heal'}
  end

  def self.spell_targets
    {1 => 'self', 2 => 'other', 3 => 'Targetted AoE', 4 => 'Caster AoE'}
  end

  def self.sub_types
    {Spell::SubTypeCold => 'cold', Spell::SubTypeFire => 'fire', Spell::SubTypeLightning =>'lightning',
     Spell::SubTypeHoly => 'holy', Spell::SubTypeUnholy => 'unholy', Spell::SubTypeAcid => 'acid',
     Spell::SubTypeArcane => 'arcane', Spell::SubTypeImpact => 'impact', Spell::SubTypeInfliction => 'infliction',
     Spell::SubTypeMalediction => 'malediction', Spell::SubTypeMental => 'mental'  }
  end

  #sort types alpabetically
  def self.spell_types_sorted_for_select
    self.spell_types.sort{|a,b|a[1].downcase<=>b[1].downcase}.collect{|t|[t.last, t.first]}
  end

  def self.sub_types_sorted_for_select
    self.sub_types.sort{|a,b| a[1].downcase <=> b[1].downcase}.collect{|t|[t.last, t.first]}
  end
  #get firs
  #t number of sort types alpabetically list
  def self.spell_types_sorted_for_select_first
    self.spell_types_sorted_for_select.first.last
  end

  def self.spell_targets_sorted_for_select
    self.spell_targets.sort{|a,b|a[1].downcase<=>b[1].downcase}.collect{|t|[t.last, t.first]}
  end

  def self.spell_targets_sorted_for_select_first
    spell_targets_sorted_for_select.first.last
  end

  def self.spell_schools_for_select
    Skill.schools.collect{|s| [s.name, s.id]}
  end

  #instance methods

  def spell_type_to_s
    Spell.spell_types[spell_type].capitalize
  end

  def spell_target_to_s
    Spell.spell_targets[spell_target].capitalize
  end
  
  def sub_type_to_s
    Spell.sub_types[sub_type].capitalize unless Spell.sub_types[sub_type].nil? 
  end

  def icon_path
    Darkfall.extract_icon_path('/assets/spells/icons/', id, icon_file_name)
  end

  #this override the friendly_id plugin to_param to utilise the SlugCache... redo once on Rails 2.3+
  def slug(reload = false)
    @most_recent_slug = nil if reload
    @most_recent_slug ||= SlugCache.query_cache(self.class.base_class, id)
    @most_recent_slug ||= slugs.first
  end


  
end
