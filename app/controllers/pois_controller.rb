class PoisController < ApplicationController

  helper :markup

  before_filter :login_required, :only => [:new, :create, :edit, :edit_submit, :update, :my_markers],
                :redirect_to => :login_path

  def index
    @pois = Poi.paginate :order => 'name ASC', :page => params[:page], :per_page => 40, :include => :slugs #TODO add setup class & make configurable
    @page_title = 'Points of Interest - Darkfall Sage'
  end

  def show
    @poi = Poi.find params[:id]
    @topics  = @poi.topics.paginate :include => [:user, :replied_by_user, :last_post], :page => params[:page_topics], :per_page => 25 #TODO add to config
    @images  = @poi.images.paginate :page => params[:page_images], :per_page => 20 #TODO add to config
    @last_approved = Poi.last_approved(@poi)
    @page_title = "#{@poi.name} - Darkfall Points of Interest - Darkfall Sage"
  end

  def new
    is_reputable_to do
      @poi = Poi.new(:poi_type => 1)
    end  
  end

  def create
    Poi.transaction do
      @poi = Poi.new(params[:poi])
      @poi.added_by = current_user.id
      if manage_poi_revisions(@poi)
        redirect_to poi_path(@poi)
      else
        render :action => 'new'
      end
    end
  end

  def edit
    is_reputable_to do
      @poi = Poi.find params[:id]
      @edit_map = Moderator.db_moderator?(current_user)
    end  
  end

  def edit_submit
    unless request.post?
      redirect_to pois_path
      return
    end
    is_reputable_to do
      @poi = Poi.find params[:id]
      @markers = @poi.markers
      @edit_map = Moderator.db_moderator?(current_user)
      if params[:delete]
        can_db_moderate do
          Poi.transaction do
            @poi.destroy
            redirect_to pois_path
          end
        end
      elsif params[:edit]
        render :action => :edit
      else
        render :text => 'invalid', :status => 404
      end
    end
  end

  def update
    Poi.transaction do
      @poi = Poi.find params[:id]
      @poi.attributes = params[:poi]
      @poi.updated_by = current_user.id
      if manage_poi_revisions(@poi)
        redirect_to poi_path(@poi)
      else
        render :action => 'edit'
      end
    end
  end

  def destroy
    can_db_moderate do
      Poi.transaction do
        poi = Poi.find params[:id]
        poi.destroy unless poi.blank?
        #
        redirect_to pois_path
      end
    end
  end

  def markers
    poi = Poi.find(params[:id])
    render :text => markers_to_markup(poi.markers.good)
  end

  def my_markers
    poi = Poi.find(params[:id])
    render :text => markers_to_markup(poi.markers.by_user(current_user))
  end

  def revisions
    show
    @show_title = "#{@poi.name.humanize} - Latest Revision - #{@poi.revision_number}"
    @revisions = @poi.revisions.collect{|rev| [rev.revisable_number, rev.revisable_original_id]}
    #
    revision
  end

  def revision
    @revision   = params[:revision].blank? ? :previous : params[:revision].to_i
    @rev_poi    = Poi.find(params[:id]).find_revision @revision
    @rev_title = "#{@rev_poi.name.humanize} - @ Revision #{@rev_poi.revision_number}" unless @rev_poi.blank?
  end

  def approve
    can_db_moderate do
      poi = Poi.find params[:id]
      updater = poi.updater || poi.user
      Poi.transaction do
        rep_type = params[:approve] ? :good : params[:reject] ? :bad : :error
        if rep_type == :good
          poi.approved_by = current_user
          poi.approved_at = Time.now
          poi.save(:without_revision => true)
        elsif rep_type == :bad #revert to previous version
          unless poi.find_revision(:previous).blank?
            poi = poi.revert_to! :previous 
            #
            poi.approved_by = current_user
            poi.approved_at = Time.now
            poi.save(:without_revision => true)
          else #delete record
            Reputation.record_reputation_by_class(:mob, poi.name, updater, current_user, rep_type) #keep as we exit after destroy
            poi.destroy
            redirect_to pois_path
            return #exit here
          end
        end
        #increase updater's reputation
        Reputation.record_reputation_by_class(:mob, poi.name, updater, current_user, rep_type)
      end
      #
      redirect_to poi_path(poi)
    end
  end

  def revert
    can_db_moderate do
      Poi.transaction do
        poi = Poi.find params[:id]
        poi = poi.revert_to! params[:revert].to_i
        poi.approved_by = current_user
        poi.approved_at = Time.now
        poi.save(:without_revision => true)
        #
        redirect_to poi_path(poi)
      end
    end
  end
  
  protected

  def manage_poi_revisions(poi)
    unless Reputation.revise?(current_user)
      poi.approved_by = current_user
      poi.approved_at = Time.now
      poi.save(:without_revision => true)
      result = true
    else #untrusted creation/revision... save, notify admin and uprev
      last = poi.revision_number.to_i
      #
      result = poi.valid?
      if result
        poi.revise! #approval cleared in mob callback
        if Reputation.revise_and_notify?(current_user)
          link = "http://darkfallsage.com/pois/#{poi.id}"
          current = poi.revision_number
          if (current > 1) #update
            diff = poi.diffs(poi.revisions.first)
            UserMailer.deliver_notify_admin_obj_edited(User.admins, poi, link, diff, current_user)
          else #create
            UserMailer.deliver_notify_admin_obj_added(User.admins, poi, link, current_user)
          end
        end
      end
    end
    result    
  end

  def poi_info_from_pid
    @poi = Poi.find params[:id]
    @topics  = @poi.topics.paginate :page => params[:page_topics], :per_page => 25 #TODO add to config
    @images  = @poi.images.paginate :page => params[:page_images], :per_page => 20 #TODO add to config
  end



end
