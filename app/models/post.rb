 
class Post < ActiveRecord::Base

  belongs_to :user
  belongs_to :topic, :counter_cache => true

  after_create  :update_topic_times
  after_create  :increment_user_posts_count
  after_destroy :set_to_last_topic_or_blank
  after_destroy :decrement_user_posts_count

  acts_as_voteable :class => 'DfVote'

  validates_presence_of :user_id, :body

  attr_accessible :body

  named_scope :good, :conditions => 'rating > -4'

  named_scope :latest, lambda{ |limit| limit ||= 5;
    {:order => 'posts.created_at DESC', :limit => limit}
  }
  named_scope :not_clans, lambda{
    {:conditions => "topic_id not in (select topics.id from topics inner join clan_forums on topics.topicable_id = clan_forums.id and topics.topicable_type = 'ClanForum' and clan_forums.access_type <> 2)"}
  }


  #instance methods
  
  def editable_by?(user)
    user && (user.id == user_id || user.admin?) #TODO user cannot edit after  mins
  end
  
  def quote_body
    quote = ''
    body.split("\n").each do |match|
      (quote << "bq. #{match}" << "\n\n") unless match.blank?
    end
    #
    "_#{user.pretty_name} said:_\n\n#{quote}"
  end
  
  def formatted_body
    body.to_redcloth
  end

  def can_vote(user)
    result = user.id != user_id
    reason = result ? '' : 'cannot vote on your own post'
    return result, reason
  end

  protected

  def update_topic_times
    Topic.update_all( ['replied_at = ?, replied_by = ?, last_post_id = ?', created_at, user_id, id], ['id = ?', topic_id])
    Topic.update_topicable_times(topic)
    update_topicable_counts
  end

  def set_to_last_topic_or_blank
    topic = Topic.find_by_id(topic_id)
    last  = topic.posts.last
    unless last.blank?
      Topic.update_all(['replied_at = ?, replied_by = ?, last_post_id = ?', last.created_at, last.user_id, last.id], ['id = ?', topic.id])
    else
      Topic.update_all(['replied_at = ?, replied_by = ?, last_post_id = ?', nil, nil, nil], ['id = ?', topic.id])
    end
    update_topicable_counts
  end

  def update_topicable_counts
    if topic.topicable.respond_to?('posts_count')
      topic.topicable.posts_count = topic.count_of_all_posts
    end
    if topic.topicable.respond_to?('topics_count')
      topic.topicable.topics_count = topic.count_of_all_topics_by_topicable
    end
    topic.topicable.save
  end

  def increment_user_posts_count
    user.create_counter if user.counter.nil?
    user.counter.posts_count += 1
    user.counter.save
  end

  def decrement_user_posts_count
    if user.counter && user.counter.posts_count > 1
      user.counter.posts_count -= 1
      user.counter.save
    end
  end
  
end
