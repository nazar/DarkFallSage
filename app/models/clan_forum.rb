class ClanForum < ActiveRecord::Base

  belongs_to :clan
  has_many :topics, :as => :topicable, :order => 'topics.sticky desc, topics.replied_at desc', :dependent => :destroy do
    def first
      @first_topic ||= find(:first)
    end
  end

  has_many :posts, :through => :topics, :order => 'posts.created_at desc' do
    def last
      @last_post ||= find(:first)
    end
  end

  validates_presence_of :name
  validates_presence_of :position
  validates_numericality_of :position
  validates_uniqueness_of :name, :scope => :clan_id

  after_create  :update_clan_forum_count
  after_destroy :update_clan_forum_count
  before_update :update_clan_topic_and_post_counts
  
  acts_as_list

  has_friendly_id :name, :use_slug => true

  named_scope :members,  {:conditions => {:access_type => [0,1,2]}}
  named_scope :alliance, {:conditions => {:access_type => [1,2]}}
  named_scope :public,   {:conditions => 'access_type = 2'}
  named_scope :ordered,  {:order => 'position'}
  named_scope :ids_only, {:select => 'clan_forums.id'}

  named_scope :by_clan_rank, lambda{|clan, user|
    unless user.blank?
      if clan.owner_id == user.id
        rank = 1
      else
        rank = user.clan_members.blank? ? 0 : user.clan_members.first.rank
      end  
    else
      rank = 0
    end
    {:conditions => ['(required_rank = 0) or (required_rank >= ? )', rank]}
  }

  #class methods

  def self.access_types
    {0 => 'Members Only', 1 => 'Members & Alliances', 2 => 'Public'}
  end

  #return list of forums and filter by supplied user depending on forum access_type
  def self.clan_forums_by_acl(clan, user)
    if user.blank?
      clan.clan_forums.public.ordered #public forums only
    elsif clan.user_is_member?(user)
      clan.clan_forums.by_clan_rank(clan, user).ordered
    elsif clan.is_member_of_alliance?(user)
      clan.clan_forums.alliance.ordered #alliance and public
    else
      clan.clan_forums.public.ordered #public only
    end
  end

  #instance methods

  def access_type_to_s
    ClanForum.access_types[access_type]
  end

  def user_can_access?(user)
    case access_type
      when 2; true
      when 1; clan.user_is_member?(user) || clan.is_member_of_alliance?(user)
      when 0;
        if required_rank > 0
          if user.id == clan.owner_id
            true
          else
            clan.user_is_member?(user) && (user.clan_members.blank?) && (user.clan_members.first.rank.to_i <= required_rank.to_i)
          end
        else
          clan.user_is_member?(user)
        end
    end
  end

  def can_admin?(user)
    unless user.blank?
      user.admin? || user.id == clan.owner_id
    else
      false
    end  
  end

  def required_rank_to_s
    if (rank = ClanMember.ranks[required_rank]).blank?
      'All Ranks'
    else
      rank
    end
  end

  def topicable_can_access(user)
    user_can_access?(user)
  end

  protected

  def update_clan_forum_count
    clan.forums_count = clan.clan_forums.length
    clan.save
  end

  def update_clan_topic_and_post_counts
    clan.topics_count = clan.clan_topics.count(:all) if topics_count_changed?
    clan.posts_count  = clan.clan_topics.sum('posts_count')  if posts_count_changed?
    clan.save
  end
  
end
