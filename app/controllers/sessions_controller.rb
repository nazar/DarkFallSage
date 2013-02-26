class SessionsController < ApplicationController

  require 'digest/md5'

  #require login for index
  before_filter :login_required, :except => [ :login, :signup, :activate, :lost_password, :password_change ]

  def index
    login
    render :action => :login
  end

  #change password
  def password
    return unless request.post?
    if User.authenticate(current_user.login, params[:old_password])
      @old_password = params[:old_password]
      if params[:password] == ''
        flash[:notice_password] = "Empty passwords not allowed."
        redirect_to :action => 'index'
        return
      end
      if (params[:password] == params[:password_confirmation])
        current_user.password_confirmation = params[:password_confirmation]
        current_user.password = params[:password]
        if not current_user.save
          flash[:notice_password] = "Password not changed. Contact admin"
        end
        flash[:notice_password] = "Password changed."
        @old_password = ''
        redirect_to :action => 'index'
        return
      else
        flash[:notice_password] = "Password mismatch"
      end
    else
      flash[:notice_password] = "Wrong old password"
    end
    redirect_to :action => 'index'
  end

  def login
    @section = 'Login'
    return unless request.post?
    password_authentication
  end

  def signup
    @section = 'Signup for a free account'
    @user = User.new(params[:user])
    return unless request.post?
    #assign user attributes manual as we are protecting auto attrb assignmnets
    @user.login                 = params[:user][:login]
    @user.password              = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    @user.email                 = params[:user][:email]
    return unless request.post?
    #TODO must agree terms
    #    @user.errors.add('terms', 'Must agree the Terms of service') if @user.terms == '0'
    save_created_user(@user) do |new_user|
      if new_user.errors.length > 0
        render :action => :signup
      else
        #notifications
        UserMailer.set_home_from_request(request)
        UserMailer.deliver_welcome_email(new_user, params[:user][:password])
        UserMailer.deliver_activate_account(new_user)
        #confirm
        render :partial => '/sessions/singup_confirmation', :layout => true
     end
    end
  end

  #activate user (if not already activated) and login
  def activate
    user = User.find_by_token(params[:token])
    unless user.nil?
      unless user.activated?
        user.activate
        user.save
        #notify admins
        UserMailer.deliver_notify_admins_signup(User.admins, user)
        #login
        self.current_user = user
        flash[:notice] = 'Account successfuly activated.'
        redirect_to  profile_path(user.login)
      else
        render :partial => '/sessions/already_activated', :layout => true
      end
    else
      render :text => '<strong>Invalid Request!</strong>', :layout => true
    end
  end

  def lost_password
    return unless request.post?
    user = User.find_by_login(params[:login]) if params[:login] != ''
    user = User.find_by_email(params[:email]) if params[:email] != ''
    if user
      token1 = Digest::MD5.digest(user.token)
      token2 = User.encrypt(user.token,"#{user.salt}--#{Configuration.md5key}--")
      #
      UserMailer.deliver_reset_password(user, token1, token2)
      #
      render :text => '<h3>An email was sent to your registerd email address with further instructions '+
        'on resetting your password.</h3>'+
        "<h3>We have logged that this request originated from #{request.remote_ip}</h3>",
        :layout => true
    else
      render :text => '<h3>Could not find an account using the supplied username or email address.</h3>',
        :layout => true
    end
    logger.info("Password reset request from #{request.remote_ip} for #{params[:login]}:#{params[:email]}")
    #tarpit
    sleep 5
  end

  def password_change
    return unless request.post?
    token = params[:id]
    user = User.find_by_md5_token(token)
    if user.length > 0
      user = user[0]
      #verify confirmation code
      token2 = User.encrypt(user.token,"#{user.salt}--#{Configuration.md5key}--")
      if token2 == params[:confirm_code]
        password      = random_string(5)
        user.password = password
        user.save
        #
        UserMailer.deliver_welcome_email(user, password)
        #
        render :text => '<h3>Your password has been reset and your new login detail have been sent to your registered email address.</h3>',
          :layout => true
      else
        render :text => '<h3>Confirmation code does not match.</h3>',
          :layout => true
      end
    else
      render :text => '<h3>Invalid token. Cannot proceed.</h3>', :layout => true
    end
  end

  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_to root_path
  end

  protected

  def password_authentication
    login = true
    self.current_user = User.authenticate(params[:user][:login], params[:user][:password])
    if self.current_user && self.current_user.activated? && self.current_user.active?
      #remember me checbox
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      self.current_user.last_seen_at = Time.now
      self.current_user.save
      redirect_back_or_default profile_path self.current_user.login
      flash[:notice] = "Logged in successfully"
    else
      if self.current_user
        unless current_user.activated?
          flash[:fatal] = 'Your account has not been activated yet. Please follow the directions that were sent to your email address: ' << current_user.email
          login = false
        end
        unless current_user.active?
          flash[:fatal] = 'Your account has been disabled. Please contact us for further asistance.'
          login = false
        end
        unless login
          self.current_user = nil
          access_denied
        end
      else
        flash[:fatal] = 'Invalid login. Please check your username and password'
      end
    end
  end

  def save_created_user(user, &block)
    User.transaction do
      user.name      = user.login #default real name to login
      user.active    = true
      user.save
      #
      user.initialise_counters if user.errors.blank?
      #post processing in block
      block.call(user)
    end
  end

end