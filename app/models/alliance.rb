class Alliance < ActiveRecord::Base

  has_many :alliance_clans
  has_many :clans, :through => :alliance_clans
  has_many :approved_clans, :through => :alliance_clans, :source => :clan, :conditions => ['alliance_clans.status = ?', AllianceClan::StatusApproved]

  has_many :alliance_logs

  belongs_to :lead_clan, :foreign_key => 'clan_owner_id', :class_name => 'Clan'

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :clan_owner_id

  has_friendly_id :name, :use_slug => true

  named_scope :with_clans, {:include => :clans}
  named_scope :ids_only, :select => 'alliances.id'

  named_scope :alliances_lead_by, lambda{|user|
    {:conditions => {:clan_owner_id => user.clans.ids_only}}
  }
  named_scope :alliances_user_part_of, lambda{|user|
    alliance_ids = AllianceClan.alliance_ids_only.by_clans(user.clans.ids_only).collect{|a| a.alliance_id}
    {:conditions => {:id => alliance_ids}}
  }



  #instance methods

  def all_clans_in_alliance
    ids = [lead_clan.id] + approved_clans.collect{|c|c.id}
    Clan.scoped(:conditions => {:id => ids})
  end

end