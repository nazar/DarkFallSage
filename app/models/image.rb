class Image < ActiveRecord::Base

  belongs_to :imageable, :polymorphic => true

  belongs_to :user

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

  after_create  :update_object_images_count
  after_destroy :update_object_images_count

  has_attached_file :picture,
                    :styles => { :large => ['640x480', 'jpg'], :preview => ['380x285#', 'jpg'], :thumbnail => ['100x75#', 'jpg']  },
                    :default_style => :preview,
                    :convert_options => { :all => "-strip" }

  validates_presence_of :title


  #class methods


  #instance methods

  #for use by topicable....as it expects name property
  def name
    title
  end


  protected

  def update_object_images_count
    if imageable.respond_to?('images_count')
      imageable.images_count = imageable.images.count
      imageable.save
    end
  end



end
