class ClanMember < ActiveRecord::Base

  belongs_to :user
  belongs_to :clan

  after_create  :update_clan_members
  after_destroy :update_clan_members

  validates_uniqueness_of :user_id, :scope => :clan_id

  #class methods

  def self.ranks
    {1 => 'Supreme General', 2 => 'General', 3 => 'Colonel', 4 => 'Major', 5 => 'Captain', 6 => 'Lieutenant',
     7 => 'Sergeant', 8 => 'Corporal', 9 => 'Private', 10 => 'Recruit'}
  end

  def self.is_member_of_clans(user, clans)
    unless clans.blank?
      clan_ids = clans.collect{|clan| clan.id}
      result =  !ClanMember.find(:first, :conditions => {:clan_id => clan_ids, :user_id => user.id}).blank?
      unless result
        result = !Clan.find(:first, :conditions => {:id => clan_ids, :owner_id => user.id}).blank?
      end
      result
    else
      false
    end
  end

  #instance methods

  def rank_to_s
    ClanMember.ranks[rank]
  end

  private

  def update_clan_members
    clan.members_count = clan.clan_members.length
    clan.save
  end


end
