module ActsAsForumable

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    def acts_as_forumable

      has_many :topics, :as => :topicable, :order => 'sticky desc, replied_at desc', :dependent => :destroy do
        def first
          @first_topic ||= find(:first)
        end
      end

      has_many :posts, :through => :topics, :order => 'posts.created_at desc' do
        def last
          @last_post ||= find(:first)
        end
      end

    end

  end


end