class News < ActiveRecord::Base

  acts_as_commentable

  belongs_to :user

  has_many :news_categories
  has_many :categories, :through => :news_categories

  validates_presence_of :title

  named_scope :by_date, :conditions => ['active = ?',true], :order => 'created_at DESC'

  has_friendly_id :title, :use_slug => true

  acts_as_forumable  

  #instance methods

  #again, an activescaffold hack as it was getting confused between article and news helpers as both admin/helpers share the same def method names
  def news_body
    body
  end

  #again, an activescaffold hack as it was getting confused between article and news helpers as both admin/helpers share the same def method names
  def news_body=(text)
    self.body = text
  end

  def news_categories_override
    categories
  end

  def news_categories_override=(blah)
    #ignore
  end

  #alias for topicable views
  def name
    title
  end

end
