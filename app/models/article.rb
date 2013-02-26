class Article < ActiveRecord::Base

  acts_as_voteable
  acts_as_taggable

  belongs_to :user

  has_many :article_categories, :dependent => :destroy
  has_many :categories, :through => :article_categories

  #forums
  has_many :topics, :as => :topicable, :order => 'sticky desc, replied_at desc', :dependent => :destroy, :include => :user do
    def first
      @first_topic ||= find(:first)
    end
  end

  has_many :posts, :through => :topics, :order => 'posts.created_at desc', :include => :user do
    def last
      @last_post ||= find(:first)
    end
  end

  validates_presence_of :title, :body

  has_friendly_id :title, :use_slug => true

  #activescaffold helper to display tags as a csv
  def article_tags
    tags.join(', ')
  end

  #activescaffold helper to accept a csv list tags and add to article
  def article_tags=(save_tags)
    tag_with(save_tags)
  end

  #forums expect a name.. redirect to title
  def name
    title
  end

end
