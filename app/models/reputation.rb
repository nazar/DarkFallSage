class Reputation < ActiveRecord::Base

  belongs_to :user

  NoAdverts = 400

  #class methods

  def self.default_reputation
    10
  end

  def self.reputation_types
    {
     :mob      => {:good => 10, :bad => -5},
     :dfmarker => {:good => 5,  :bad => -2},
     :post     => {:good => 10, :bad => -2}
    }
  end

  def self.record_reputation_by_class(rep_type, update_name, update_user, approve_user, rating_type = :good )
    raise "rating must be either :good or :bad" unless (rating_type == :good) || (rating_type == :bad)
    raise "rep_type #{rep_type} invalid" if Reputation.reputation_types[rep_type].blank?
    #
    rating = Reputation.reputation_types[rep_type][rating_type]
    #update totals
    unless update_user.blank?
      update_user.initialise_counter_if_required
      update_user.counter.reputation += rating
      update_user.counter.save
      #add entry in history
      vote_desc = rating_type == :good ? 'upvoted' : 'downvoted'
      history = "#{update_name} - #{vote_desc} - #{rating} reputation"
      Reputation.create(:user_id => update_user.id, :reputation => rating, :updated_by => approve_user.id,
                        :reason => history, :total => update_user.counter.reputation)
      #deduct one repuation from reportee unless a moderator
      if (rating_type == :bad) && (!Moderator.db_moderator?(approve_user))
        rating = -1
        approve_user.counter.reputation += rating
        approve_user.counter.save
        #
        Reputation.create(:user_id => approve_user.id, :reputation => rating, :updated_by => update_user.id,
                          :reason => "Downvoting cost 1 reputation", :total => approve_user.counter.reputation)
      end
    end   
  end

  def self.revise?(user)
    !(user && Moderator.db_moderator?(user))
  end

  def self.revise_and_notify?(user)
    Reputation.revise?(user) && user.counter.reputation < 200
  end

  

  #instance methods

end
