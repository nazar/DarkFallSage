class Poi < ActiveRecord::Base

  belongs_to :user,     :foreign_key => 'added_by'
  belongs_to :updater,  :foreign_key => 'updated_by', :class_name => 'User'
  belongs_to :approver, :foreign_key => 'approved_by', :class_name => 'User'

  has_many :images, :as => :imageable

  has_many :topics, :as => :topicable, :order => 'sticky desc, replied_at desc', :dependent => :destroy, :include => :user do
    def first
      @first_topic ||= find(:first)
    end
  end

  has_many :posts, :through => :topics, :order => 'posts.created_at desc', :include => :user do
    def last
      @last_post ||= find(:first)
    end
  end

  validates_presence_of :name
  validates_uniqueness_of :name

  acts_as_markable :class => 'DfMarker'

  has_friendly_id :name, :use_slug => true

  acts_as_revisable do
    except :added_by, :updated_by, :images_count, :markers_count, :topics_count, :posts_count
  end
  before_revise :clear_approvals_if_not_admins!

  TypeBank      = 1
  TypeTower     = 2
  TypeTown      = 3
  TypeDungeon   = 4
  TypeBindStone = 5
  TypeChest     = 6
  TypeNPC       = 7
  TypeMisc      = 8

  #class methods

  def self.poi_types
    {Poi::TypeBank => 'bank', Poi::TypeTower => 'tower', Poi::TypeTown => 'town', Poi::TypeDungeon => 'dungeon', 
     Poi::TypeBindStone => 'bind stone', Poi::TypeChest => 'chest', Poi::TypeNPC => 'npc', Poi::TypeMisc => 'miscellaneous'  }
  end

  def self.poi_types_for_select
    Poi.poi_types.sort{|a,b|a[1]<=>b[1]}.collect{|i|[i.last, i.first]}
  end

  def self.last_approved(poi)
    Poi.without_model_scope do
      Poi.find(:all, :conditions => ['((revisable_original_id = ?) or (id = ?)) and approved_by is not null', poi.id, poi.id],
               :order => 'approved_at DESC', :limit => 1).first
    end
  end

  #instance methods

  def poi_type_to_s
    Poi.poi_types[poi_type]
  end

  private

  def clear_approvals_if_not_admins!
    if !is_reverting?
      unless Moderator.db_moderator?(updater)
        self.approved_by = nil
        self.approved_at = nil
      end
    end
  end


end
