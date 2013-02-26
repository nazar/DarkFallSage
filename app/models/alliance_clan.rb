class AllianceClan < ActiveRecord::Base

  belongs_to :clan
  belongs_to :alliance

  named_scope :with_clans, {:include => :clan}

  after_create  :update_clan_counter
  after_destroy :update_clan_counter
  after_update  :update_clan_counter  

  StatusPending  = 0
  StatusApproved = 1
  StatusRejected = 2
  StatusInvited  = 3

  named_scope :approved, {:conditions => ['alliance_clans.status = ?', AllianceClan::StatusApproved]}
  named_scope :pending,  {:conditions => ['alliance_clans.status = ?', AllianceClan::StatusPending]}
  named_scope :invited,  {:conditions => ['alliance_clans.status = ?', AllianceClan::StatusInvited]}

  named_scope :alliance_ids_only, {:select => 'alliance_clans.alliance_id'}

  named_scope :by_clans, lambda{|clans|
    ids = clans.collect{|c| c.id}
    {:conditions => {:clan_id => ids}}
  }

  #class methods


  def self.unique_token
    token = String.random_string(15)
    if AllianceClan.find_by_token(token).to_a.length > 0
      AllianceClan.unique_token
    else
      token
    end
  end

  def self.new_for_alliance_clan(alliance, clan)
    alliance.alliance_clans.new(:clan_id => clan.id, :token => AllianceClan.unique_token)
  end

  def self.statuses
    {StatusPending => 'pending', StatusApproved => 'approved', StatusRejected => 'rejected', StatusInvited => 'invited'}
  end

  #instance methods

  def status_to_s
    AllianceClan.statuses[status]
  end

  private

  def update_clan_counter
    if status == AllianceClan::StatusApproved
      alliance.clans_count = alliance.alliance_clans.approved.length + 1 # +1 as we start at 1 as that includes the owning clan
      alliance.save
    end  
  end



end
