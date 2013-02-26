class MapsController < ApplicationController

  helper :item, :mobs, :votes

  verify :method => :post, :only => [ :add_marker, :remove_marker ],
         :redirect_to => { :action => :index }

  before_filter :login_required, :except => [ :index, :latest, :info, :add_obj_marker ]

  include ActionController::UrlWriter #for routing in add_obj_marker

  def index
    @page_title = 'Darkfall Sage World Map'
  end

  def add_marker
    is_reputable_to do
      obj = params[:markable_type].constantize.find(params[:markable_id])
      unless obj.blank?
        markable = params[:markable]
        if (markable[:xs].length > 0) && (markable[:ys].length > 0) #hax... don't check for all
          marker = DfMarker.create(:user_id => current_user.id, :title => markable[:title],
                                 :markable_type => params[:markable_type], :markable_id => params[:markable_id],
                                 :xm => markable[:xm], :xs => markable[:xs], :xd => markable[:xd].upcase,
                                 :ym => markable[:ym], :ys => markable[:ys], :yd => markable[:yd].upcase,
                                 :lat => markable[:lat], :lng => markable[:lng])
          obj.add_marker(marker)
        end
        #update view
        respond_to do |format|
          format.html {redirect_to root_path}
          format.js do
            render :update do |page|
              page.replace_html 'marker_list', :partial => '/maps/list', :locals => {:markable => obj}
            end
          end
        end
      end
    end  
  end

  def add_obj_marker
    is_reputable_to do
      obj = params[:markable_type].constantize.find(params[:markable_id])
        unless obj.blank?
          respond_to do |format|
            format.html {redirect_to root_path}
            format.js do
              data_url = send("#{obj.class.name.downcase}_my_markers_path", current_user.id, obj.id)
              render :update do |page|
                page.replace 'google_map', :partial => 'maps/markable_edit', :locals => {:markable => obj, :data_url => data_url,
                                                                                         :markers => obj.markers.by_user(current_user)}
              end
            end
          end
        end
    end
  end

  def remove_marker
    #should have a has in params called delete.
    to_delete = params[:delete]
    unless to_delete.blank?
      #check these markers belong to this object
      markable = params[:markable_type].constantize;
      markable = markable.find_by_id(params[:markable_id].to_i)
      if markable
        objs = markable.markers.find(to_delete.values)
        objs.each{|m| m.destroy if (m.user_id == current_user.id) or (current_user.admin)}
      end
      #render marker list
      render :update do |page|
        page.replace_html 'marker_list', :partial => '/maps/list', :locals => {:markable => markable}
      end
    else
      render :nothing => true
    end
  end

  #return last x markers
  def latest
    markers = DfMarker.good
    render :text => markers_to_markup(markers)
  end

  def info
    @marker = DfMarker.find_by_id params[:id]
    get_vote_info
    if @marker.markable.is_a? Item
      @item = @marker.markable
      render :partial => 'items/map_popup_info'
    elsif @marker.markable.is_a? Mob
      @mob = @marker.markable
      render :partial => 'mobs/map_popup_info'
    elsif @marker.markable.is_a? Poi
      @poi = @marker.markable
      render :partial => 'pois/map_popup_info'
    end
  end

  protected

  def get_vote_info
    @votes_for     = @marker.votes_for
    @votes_against = @marker.votes_against
    @can_vote      = DfMarker.can_vote?(current_user, @marker)  #mod added items non votable
    if current_user
      @voted_for     = current_user.voted_for?(@marker)
      @voted_against = current_user.voted_against?(@marker)
    end  
  end

end