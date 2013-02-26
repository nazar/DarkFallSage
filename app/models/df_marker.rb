class DfMarker < Marker

  acts_as_voteable :class => 'DfVote'

  named_scope :good, :conditions => 'rating > -4'
  named_scope :by_user, lambda{|user|
    {:conditions => ['user_id = ?', user.id]}
  }

  #object not votable if added by a moderator or has sufficient reputation. Show block for anon but will be redirected to login
  def self.can_vote?(user, marker)
    user.blank? || (not marker.user.admin) && (user.counter.reputation > 0)
  end

  #instance methods

  def can_vote(user)
    result = user.id != user_id
    reason = result ? '' : 'cannot vote on your own marker'
    return result, reason
  end

  
end