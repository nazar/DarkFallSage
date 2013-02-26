class Ability < ActiveRecord::Base

  acts_as_commentable

  has_many :needed_by, :as => :need, :class_name => 'Prereq'


  has_many :topics, :as => :topicable, :order => 'sticky desc, replied_at desc', :dependent => :destroy, :include => :user do
    def first
      @first_topic ||= find(:first)
    end
  end

  has_many :posts, :through => :topics, :order => 'posts.created_at desc', :include => :user do
    def last
      @last_post ||= find(:first, :include => :user)
    end
  end

  
  has_attached_file :icon,
                    :styles => { :original => ['32x32#', "jpg"] },
                    :default_style => :original,
                    :default_url => "/images/missing.png",
                    :convert_options => { :all => "-strip" }

  has_friendly_id :name, :use_slug => true  
  

end
