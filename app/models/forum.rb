class Forum < ActiveRecord::Base

  has_many :topics, :as => :topicable, :order => 'topics.sticky desc, topics.replied_at desc', :dependent => :destroy do
    def first
      @first_topic ||= find(:first)
    end
  end

  has_many :posts, :through => :topics, :order => 'posts.created_at desc' do
    def last
      @last_post ||= find(:first, :include => :user)
    end
  end

  acts_as_list

  validates_presence_of :name

  

end
