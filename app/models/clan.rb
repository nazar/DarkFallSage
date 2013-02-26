class Clan < ActiveRecord::Base

  belongs_to :owner, :foreign_key => 'owner_id', :class_name => 'User'

  has_many :clan_forums
  has_many :images, :as => :imageable
  has_many :clan_applications, :include => :user
  has_many :applicants, :through => :clan_applications

  has_many :clan_members, :include => :user
  has_many :members, :through => :clan_members, :source => :user
  has_many :alliance_clans
  has_many :alliances, :through => :alliance_clans, :conditions => ['alliance_clans.status = ?', AllianceClan::StatusApproved]

  has_many :owned_alliances, :foreign_key => 'clan_owner_id', :class_name => 'Alliance'
  has_many :alliance_requests, :through => :owned_alliances, :source => :alliance_clans

  has_many :clan_invites, :include => :invitee


  validates_presence_of :name
  validates_uniqueness_of :name

  has_friendly_id :name, :use_slug => true

  has_attached_file :crest,
                    :styles => { :original => ['128x128#', "jpg"]  },
                    :default_style => :original,
                    :default_url => "/images/no-crest.png",
                    :convert_options => { :all => "-strip" }

  named_scope :all_by_name, :order => 'name ASC'
  named_scope :ids_only, :select => 'clans.id' 

  named_scope :clans_allied_to, lambda{|clan|
    alliances = clan.alliances + clan.owned_alliances
    clan_ids  = alliances.collect{|alliance| alliance.all_clans_in_alliance.collect{|c| c.id}}.flatten
    clan_ids.delete(clan.id)
    {:conditions => {:id => clan_ids}}
  }

  ByInvitation  = 0
  ByApplication = 1
  OpenToAll     = 2

  #class methods

  def self.servers
    {0 => 'EU1', 1 => 'US1'}
  end

  def self.access_types
    {ByInvitation => 'By Invitation', ByApplication => 'By Application', OpenToAll => 'Open to All'}
  end


  #instance methods

  def server_to_s
    Clan.servers[server]
  end

  def access_type_to_s
    Clan.access_types[access_type]
  end

  def user_is_member?(user)
    unless user.blank?
      (user.id == owner_id) ||(not members.find_by_id(user.id).blank?) 
    else
      false
    end  
  end

  # is user a clan member of any of our allied clans?
  def is_member_of_alliance?(user)
    ClanMember.is_member_of_clans(user, Clan.clans_allied_to(self).ids_only)
  end

  #currently only club owner can admin a club... later introduce ranks...
  def can_admin?(user)
    if user.blank?
      false
    else
      user.id == owner_id
    end
  end

  def already_applied?(user)
    not clan_applications.not_rejected.find_by_user_id(user.id).blank?
  end

  def can_join?(user)
    unless user.blank?
      (not user.in_clan_or_owns_clan?) && (not already_applied?(user))
    else
      false
    end  
  end

  def clan_topics
    forums = clan_forums.ids_only.collect{|c| c.id}
    Topic.scoped(:conditions => {:topicable_type => 'ClanForum', :topicable_id => forums})
  end

  def can_upload_images?(user)
    unless user.blank?
      user_is_member?(user) || is_member_of_alliance?(user) 
    else
      false
    end
  end

end
