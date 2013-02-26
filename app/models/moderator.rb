class Moderator < ActiveRecord::Base

  belongs_to :user

  #class methods

  def self.is_cached_moderator(user)
    @cache ||= Moderator.all.collect{|m| m.user_id}
    @cache.include?(user.id)
  end

  def self.forum_moderator?(user)

  end

  def self.db_moderator?(user)
    if user.nil?
      false
    else
      user.admin? || (Moderator.count(:conditions => ['user_id = ? and can_db = ?', user.id, true]) > 0)
    end
  end

end
