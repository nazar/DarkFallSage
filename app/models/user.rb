class User < ActiveRecord::Base

  require 'digest/sha1'

  has_one :profile, :class_name => 'UserProfile'
  has_one :counter, :class_name => 'UserCounter'

  has_many :articles
  has_many :comments
  has_many :topics
  has_many :posts
  has_many :reputations
  has_many :clans, :foreign_key => 'owner_id' #techincally only one clan allowed... but easier to manage.
  has_many :clan_applications
  has_many :applied_to_clans, :through => :clan_applications

  has_many :clan_members
  has_many :member_of_clan, :through => :clan_members, :source => :clan

  has_many :clan_invites, :foreign_key => 'invitee'

  has_many :markers
  has_karma :markers
  has_karma :posts

  
  # Virtual attribute for the un-encrypted password
  attr_accessor :password, :password_confirmation

  validates_presence_of     :login, :email
#  validates_inclusion_of    :terms, :in => ['1'], :message => 'must be agreed', :if => :term_required?
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  validates_format_of       :login, :with => /^[a-z0-9_-]+$/i, :message => 'may only contain letters (a-z), numbers (0-9), underscores (_) or dashes (-)'

  before_save :encrypt_password
  before_save :create_user_token

  attr_protected :admin, :activated, :active, :crypted_password, :salt, :token, :login, :password, :email

  named_scope :activated, :conditions => ['activated = ?', true]
  named_scope :active_members, :conditions => ['activated = ? and active = ?', true, true]
  named_scope :admins, :conditions => {:admin => true}

  acts_as_voter :class => 'DfVote', :dependant => :destroy
  
  has_attached_file :avatar,
                    :styles => { :original => ['64x64#', 'jpg'] },
                    :default_style => :original,
                    :default_url => "/images/no_avatar_s.gif",
                    :convert_options => { :all => "-strip" }

  has_attached_file :profile_image,
                    :styles => { :original => ['225x300#', 'jpg'] },
                    :default_style => :original,
                    :default_url => "/images/no_avatar_l.gif",
                    :convert_options => { :all => "-strip" }

  validates_attachment_content_type :profile_image,
    :content_type => ["image/jpeg", "image/png", "image/gif"],
    :message => "Oops! Make sure you are uploading an image file. Only jpg, png and gif files allowed"  

  #class methods

  def self.find_by_md5_token(token)
    User.find_by_sql(['select * from users where md5(token) = ?',token])
  end

  def self.all_emails
    User.find(:all).map{|m| m.email}
  end

  def self.currently_online
    User.find(:all, :conditions => ["last_seen_at > ?", Time.now.utc-5.minutes])
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  def self.top_reputation(limit = 10)
    users = UserCounter.top_reputation(limit).collect{|c|c.user_id}
    User.scoped(:conditions => {:id => users})
  end

  #instance methods

  def formatted_bio
    Misc.format_red_cloth(bio)
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  def pretty_name
    unless name.blank?
      name
    else
      login
    end
  end

  #setup defaults for a newly created user
  def setup_new_user(login, password, email)
    self.login = login
    self.email = email
    self.password  = password
    self.password_confirmation = password
    self.remember_me
  end

  def activate
    self.activated = true
    self.active    = true
  end

  def posts_count
    cnt =  counter.nil? ? create_counter : counter
    cnt.posts_count
  end

  def increment_posts_count
    cnt = counter.nil? ? create_counter : counter
    cnt.posts_count += 1
    cnt.save
  end

  def initialise_counters
    create_counter(:reputation => Reputation.default_reputation)
  end

  def initialise_counter_if_required
    initialise_counters if counter.blank? 
  end

  def in_clan_or_owns_clan?
    clans.to_a.length + member_of_clan.to_a.length > 0
  end

  def my_alliance_ids
    if @user_alliances_id_cache.nil?
      owned_allianced   = Alliance.alliances_lead_by(self).ids_only.collect{|a|a.id}
      my_clan_alliances = Alliance.alliances_user_part_of(self).ids_only.collect{|a|a.id}
      @user_alliances_id_cache = owned_allianced + my_clan_alliances
    else
      @user_alliances_id_cache
    end
  end

  def my_allied_clan_ids
    unless clans.blank?
      Clan.clans_allied_to(clans.first).ids_only.collect{|c| c.id}
    else
      []
    end  
  end

  def clan_member_and_owner_of_ids
    clans.ids_only + member_of_clan.to_a.length > 0
  end

  def calc_rank
    if admin
      'Administrator'
    elsif Moderator.is_cached_moderator(self)
      'Moderator'
    else
      'Member'
    end
  end


  protected

  # before filter
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("+--#{Time.now.to_s}-+-#{login}--+") if new_record?
    self.crypted_password = encrypt(password)
  end

  def create_user_token
    return unless token.blank?
    self.token = String.random_string(10)
  end

  def password_required?
    crypted_password.blank? || !password.blank?
  end

end