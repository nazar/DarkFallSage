class ClanInvite < ActiveRecord::Base

  belongs_to :clan
  belongs_to :invitee, :foreign_key => 'invitee', :class_name => 'User'
  belongs_to :inviter, :foreign_key => 'inviter', :class_name => 'User'

  ResponsePending = 0
  ResponseAccept  = 1
  ResponseReject  = 2

  named_scope :pending, :conditions => ['response <> ?', ClanInvite::ResponseAccept]

  #class methods

  def self.unique_token
    token = String.random_string(15)
    if ClanInvite.find_by_token(token).to_a.length > 0
      ClanInvite.unique_token
    else
      token
    end
  end

  def self.new_for_clan_invite(clan, user)
    clan.clan_invites.create(:invitee => user, :token => ClanInvite.unique_token)
  end

  def self.responces
    {ResponsePending => 'pending', ResponseAccept => 'accepted', ResponseReject => 'rejected'}
  end

  #instance methods

  def response_to_s
    ClanInvite.responces[response]
  end
  

end
