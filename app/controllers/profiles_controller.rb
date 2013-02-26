class ProfilesController < ApplicationController

  require 'digest/md5'

  helper :markup

  before_filter :login_required, :except => [ :show ]

  def index
    if current_user
      redirect_to profile_path(current_user.login)
    else
      redirect_to session_login_path
    end
  end

  def show
    get_user_from_login
    index if @user.nil?
    @latest_topics = @user.topics.and_public_clans.all_includes.latest.all :order => 'updated_at DESC'
    @latest_posts  = @user.posts.not_clans.latest.all :include => [:topic, :user]
    @section = @title = "#{@user.pretty_name}'s Profile"
  end

  def edit
    get_user_from_login
    @section = @title = "Editing My Details"
    return unless request.post?
    #can only update my own profile... and only valid for real users
    index if @user.nil? || (@user.id != current_user.id)
    if @user.id == current_user.id
      @user.update_attributes(params[:user])
      if @user.profile.nil?
        @user.create_profile(params[:profile])
      else
        @user.profile.update_attributes(params[:profile])
      end
    end
    index
  end

  #manage profiles images, both the profile_image and forum avatar
  def images
    get_user_from_login
    unless @mine
      render :partial => '/shared/invalid_request', :layout => true
      return
    end
    @title = @section = 'Manage Profile Image and Forum Avatar'
    return unless request.post?
    #several possibilities here...
    if params[:user] && params[:user][:profile_image] #updating profile_image and maybe use image for forum
      @user.profile_image = params[:user][:profile_image]
      @user.save
      if params[:use_for_forum]
        params[:user][:avatar] = params[:user][:profile_image] #hack otherwise paperclip gets confused
        @user.avatar      = params[:user][:avatar]
        @user.save
      end
      flash[:notice] = 'Profile Image Updated'
    elsif params[:user] && params[:user][:avatar] #update avatar
      @user.avatar = params[:user][:avatar]
      flash[:notice] = 'Avatar Updated'
    elsif params[:clear_profile_image]
      @user.clear_profile_image
    elsif params[:clear_avatar]
      @user.clear_avatar
    else
      render :partial => '/shared/invalid_request', :layout => true
      return
    end
    @user.save
    redirect_to images_profile_path(@user.login)
  end

  protected

  def get_user_from_login
    @user = User.find_by_login params[:login]
    unless @user.nil?
      @profile = @user.profile.nil? ? UserProfile.new : @user.profile
      @counter = @user.counter.nil? ? UserCounter.new : @user.counter
      @mine = current_user && (@user.id == current_user.id)
    end
  end

end