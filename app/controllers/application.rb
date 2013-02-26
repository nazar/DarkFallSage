class ApplicationController < ActionController::Base

  include AuthenticatedSystem
  include BrowserFilters

  #helper :all # include all helpers, all the time

  helper :blocks #everybody should have access to this

  protect_from_forgery 
  
  filter_parameter_logging :password

  session :session_key => '_darkfall_id'
  session :secret => 'some_really_long_and_hashed_key some_really_long_and_hashed_key'

  before_filter :login_from_cookie
#  before_filter :dos_protection

  helper_method :current_user, :logged_in?, :admin?, :last_active

  cache_sweeper :block_sweeper

  #session :off, :if => proc { |request| Utility.robot?(request.user_agent) }
  #
  #class Utility
  #  def self.robot?(user_agent)
  #    user_agent =~ /(Baidu|bot|Google|SiteUptime|Slurp|WordPress|ZIBB|ZyBorg|Yahoo)/i
  #  end
  #end


protected

  #for use by before_filter to obtain login path on redirect
  def login_path
    session_login_path
  end

  def save_prereqs(prereqable)
    unless params[:prereq].blank?
      params[:prereq].each do |key, value|
        Prereq.add_or_update_prereq(prereqable, key, value[:prereq_type], value[:prereq_id], value[:qty])
      end
    end
  end

  def can_db_moderate
    if Moderator.db_moderator?(current_user)
      yield
    else
      render :text => 'Only a moderator can edit this object', :layout => true
    end
  end

  def markers_to_markup(markers)
    unless markers.blank?
      out = []
      markers.each do |m|
        out << "#{m.xm}^#{m.xs}^#{m.xd}^#{m.ym}^#{m.ys}^#{m.yd}^#{m.title.gsub('^',' ')}^#{m.id}^#{m.markable_type}"
      end
      return out.join(';')
    else
      return '-1'
    end
  end

  def is_reputable_to
    return true unless block_given?
    if current_user.blank?
      respond_to do |format|
        format.html{redirect_to session_login_path}
        format.js do
          render :update do |page|
            page.redirect_to session_login_path
          end
        end
      end
    else
      if current_user.counter
        result = (current_user.counter.reputation > 0) || Moderator.db_moderator?(current_user)
      else
        current_user.initialise_counters
        result = true
      end
      if result
        yield
      else
        respond_to do |format|
          format.html {render :partial => 'shared/no_privs', :layout => true}
          format.js do
            if params[:ptype] && params[:ptype] == 'jq'
              render :text => '<h3>Insufficient Reputation to perform this task</h3>'
            else
              render :update do |page|
                page.alert 'Insufficient Reputation to perform this task'
              end
            end
          end
        end
      end
    end  
  end

  def topicable_can_access(topicable, user)
    if topicable.respond_to?('topicable_can_access')
      result = topicable.send('topicable_can_access', user)
    else
      result = true
    end
    if result
      yield
    else
      render :text => 'Cannot access this forum due to permissions', :layout => true
    end
  end

  def cache_slug_items(collection, class_to_s)
    ids = collection.select{|item| item.id}
    Slug.find :all, :conditions => {:sluggable_type => class_to_s, :sluggable_id => ids}
  end


  def can_admin_clan(clan, user)
    raise "must supply a block" unless block_given?
    if clan.can_admin?(user)
      yield
    else
      render :partial => 'clans/cannot_admin', :layout => true
    end
  end

  def clear_slug_cache
    SlugCache.clear_cache
  end

end
