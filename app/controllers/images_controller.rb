class ImagesController < ApplicationController

  helper :markup

  before_filter :login_required, :only => [:new, :create, :edit, :update, :destroy], :redirect_to => :login_path

  def new
    @imageable = find_imageable
    @image     = @imageable.images.build
    respond_to do |format|
      format.html{}
      format.js  {render :partial => 'images/ajax_post_form', :locals => {:imageable => @imageable, :image => @image} }
    end
  end

  def create
    @imageable = find_imageable
    Image.transaction do
      image = @imageable.images.build(params[:image])
      image.user_id = current_user.id
      image.save
      #
      unless image.errors.blank?
        render :action => :new
      else
        respond_to do |format|
          format.html { redirect_to image_path(image.id) }
          format.js   { render :nothing => true }
        end
      end
    end  
  end
  
  def show
    unless params[:id].blank?
      @image = Image.find params[:id]
      @image_url = request.protocol + request.host_with_port + @image.picture.url(:large)
      @topics = @image.topics.paginate :include => [:user, :replied_by_user, :last_post],
                                       :page => params[:page], :per_page => 25 #TODO add to config
      @page_title = "#{@image.title} - Darkfall Sage"
      respond_to do |format|
        format.html{}
        format.js  {render :partial => 'images/ajax_image_popup'}
      end
    else
      redirect_to root_path
    end
  end

  protected

  def find_imageable
    params[:imageable_type].constantize.find(params[:imageable_id])
  end
  
end
