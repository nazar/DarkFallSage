class Topic < ActiveRecord::Base
  
  belongs_to :topicable, :polymorphic => true
  belongs_to :user
  belongs_to :replied_by_user, :foreign_key => 'replied_by', :class_name => 'User'
  belongs_to :last_post, :foreign_key => 'last_post_id', :class_name => 'Post'

  has_many :posts, :order => 'posts.created_at', :dependent => :destroy, :include => :user do
    def last
      @last_post ||= find(:first, :order => 'posts.created_at desc')
    end
  end


  validates_presence_of :user, :title

  before_create { |r| r.replied_at = Time.now.utc }

  named_scope :all_includes, {:include => [:user, :replied_by_user, :last_post]} 
  named_scope :not_clans, {:conditions => ['topicable_type <> ?', 'ClanForum']}

  named_scope :latest, lambda{ |limit| limit ||= 5;
    {:order => 'topics.created_at DESC', :limit => limit}
  }
  named_scope :and_public_clans, lambda{
    public_forums = ClanForum.public.ids_only.collect{|cf| cf.id}
    unless public_forums.blank?
      conditions = "(topicable_type <> 'ClanForum') or ((topicable_type = 'ClanForum') and (topicable_id in (#{public_forums.join(',')})))"
    else
      conditions = "(topicable_type <> 'ClanForum')"
    end
    {:conditions => conditions}
  }

  # to help with the create form
  attr_accessor :body
  
  #class methods
  
  def self.latest_topics(limit=10)
    topics = Topic.find( :all, :order => 'created_at DESC', :limit => limit)
    if block_given?
      topics.map {|t| yield t}
    else
      topics
    end
  end
  
  def self.next_topic(topic)
    #get first topic posted after this topic on the same forum
    tpc = Topic.find( :all, 
                      :conditions => ['topicable_id = ? and topicable_type = ? and created_at < ?', topic.topicable_id, topic.topicable_type, topic.created_at],
                      :limit => 1,
                      :order => 'created_at DESC')
    if tpc
      return tpc[0]
    else
      return false
    end
  end
  
  def self.prev_topic(topic)
    tpc = Topic.find( :all, 
                      :conditions => ['topicable_id = ? and topicable_type = ?  and created_at > ?', topic.topicable_id, topic.topicable_type, topic.created_at],
                      :limit => 1,
                      :order => 'created_at DESC')
    if tpc
      return tpc[0]
    else
      return false
    end
  end

  def self.create_topic_and_post_from_params(params, topicable, user, ip)
    Topic.transaction do
      topic       = topicable.topics.build(params)
      topic.user  = current_user
      if current_user.admin?
        topic.locked   = params[:locked]
        topic.sticky   = params[:sticky]
      end
      topic.save
      post = nil
      if topic.errors.blank?
        #next create the first post in the topic
        post = topic.posts.build(params)
        post.user = user
        post.ip = ip
        post.body = topic.title if post.body.blank?
        post.save
      end 
      #
      return topic, post
    end
  end

  #check if attached topicable has a last_posted field.. if so, update
  def self.update_topicable_times(topic)
    if topic.topicable.respond_to?('last_posted')
      topic.topicable.last_posted = Time.new
      topic.topicable.save
    end
  end
  
  #instance methods
  
  def voices
    posts.map { |p| p.user_id }.uniq.size
  end
  
  def hit!
    self.class.increment_counter :hits, id
  end

  def sticky?() sticky == 1 end

  def views() hits end

  def paged?() posts_count > 25 end #TODO number of pages in Config class
  
  def last_page
    (posts_count.to_f / 25.0).ceil.to_i #TODO number of pages in Config class
  end
  
  def editable_by?(user)
    user && (user.id == user_id || user.admin? ) #TODO user can only edit post after x mins
  end

  #find all topics under a topicable and sum of all posts under these topics
  def count_of_all_posts
    Topic.count_by_sql("select count(id) from posts where posts.topic_id in (select topics.id from topics where topics.topicable_id = #{topicable.id} and topics.topicable_type = '#{topicable.class.to_s}')")
  end

  #find all count of all topics under a topicable 
  def count_of_all_topics_by_topicable
    Topic.count_by_sql("select count(id) from topics where topics.topicable_id = #{topicable.id} and topics.topicable_type = '#{topicable.class.to_s}'")
  end

  def last_post_body
    last_post.body unless last_post.blank?
  end
  
end
