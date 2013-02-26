class Skill < ActiveRecord::Base

  has_many :prereqs, :as => :prereqable
#  has_many :skills, :through => :prereqs
#  has_many :items,  :through => :prereqs
#  has_many :spells, :through => :prereqs, :source => :prereqable
  
  has_many :needed_by, :as => :need, :class_name => 'Prereq'
#  has_many :needed_by_spells, :as => :need, :class_name => 'Prereq', :conditions => ['prereqable_type = ?', 'Spell'], :include => :need
#  has_many :spells, :through => :needed_by, :class_name => 'Prereq', :source => :spell

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

  has_many :spells, :foreign_key => 'school_id' 

  named_scope :schools, :conditions => ['magic_school = ?', true], :order => 'name'

  named_scope :skills_by_type, lambda{|skill_type|
    {:conditions => {:skill_type => skill_type.to_i}}
  }

  named_scope :required_by_item, lambda{ |item|
    {:select => 'skills.*, prereqs.qty',
     :joins => 'inner join prereqs on prereqs.prereqable_id = skills.id',
     :conditions => ['prereqs.need_id = ? and prereqs.need_type = ? and prereqs.prereqable_type = ?', item.id, 'Item', 'Skill']
    }
  }


  validates_presence_of :name
  validates_uniqueness_of :name

#  named_scope :spell_schools, :conditions => 'skill_type = 4 and skill_sub_type is null'

  has_attached_file :icon,
                    :styles => { :original => ['32x32#', "jpg"] },
                    :default_style => :original,
                    :default_url => "/images/missing.png",
                    :convert_options => { :all => "-strip" }

  has_friendly_id :name, :use_slug => true   

  #class methods

  def self.skill_types
    {1 => 'combat', 2 => 'crafting', 3 => 'general', 4 => 'magic', 5 => 'weapon'}
  end

  def self.magic_skill_schools
    {1 => 'lesser magic', 2 => 'greater magic', 3 => 'spell chanting', 4 => 'witchcraft', 5 => 'water magic',
     6 => 'fire magic', 7 => 'earth magic', 8 => 'air magic', 9 => 'arcane magic', 10 => 'necromancy'}
  end

  def self.skill_sub_types(skill_type = nil)
    subs = {
      4 => Skill.magic_skill_schools
      }
    unless skill_type.nil?
      subs[type]
    else
      subs
    end
  end

  def self.skill_type_for_select
    Skill.skill_types.sort{|a,b|a[1]<=>b[1]}.collect{|s|[s.last, s.first]}
  end

  def self.skill_magic_schools_for_select
    Skill.magic_skill_schools.sort{|a,b|a[0]<=>b[0]}.collect{|s|[s.last, s.first]}
  end

  def self.skill_race_limits
    UserProfile.game_races.merge({0 => 'No'})
  end

  def self.skill_race_limits_sorted_for_select
    Skill.skill_race_limits.sort{|a, b| a[0] <=> b[0]}.collect{|i|[i.last, i.first]}
  end

  def self.magic_skill_school_skills
    Skill.all(:conditions => ['magic_school = ?', true], :order => 'name').collect{|skill| [skill.name, skill.id]} 
  end

  def self.all_as_type_hash
    result = {}
    Skill.all(:include => :slugs).each{|skill| result[skill.skill_type].blank? ? result[skill.skill_type] = [skill] : result[skill.skill_type] << skill}
    sorted = Skill.skill_types.sort{|a,b|a[1]<=>b[1]}.collect{|s|[s.first]}.flatten
    return sorted, result
  end

  #instance methods

  def skill_type_to_s
    Skill.skill_types[skill_type].capitalize unless Skill.skill_types[skill_type].blank?
  end

  def has_subtype?
    (not skill_sub_type.blank?) && (not Skill.skill_sub_types[skill_type].blank?)
  end

  def skill_subtype_to_s
    if has_subtype?
      Skill.skill_sub_types[skill_type][skill_sub_type]
    else
      ''
    end
  end

  def limited_to_race_to_s
    Skill.skill_race_limits[limited_to_race]
  end

  def icon_path
    Darkfall.extract_icon_path('/assets/skills/icons/', id, icon_file_name)
  end

  #this override the friendly_id plugin to_param to utilise the SlugCache... redo once on Rails 2.3+
  def slug(reload = false)
    @most_recent_slug = nil if reload
    @most_recent_slug ||= SlugCache.query_cache(self.class.base_class, id)
    @most_recent_slug ||= slugs.first
  end
  

end
