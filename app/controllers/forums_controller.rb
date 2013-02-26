class ForumsController < ApplicationController

  helper :markup

def index
    @forums = Forum.all
    @page_title = 'Viewing Forums Index'
  end
  
  def show
    @forum  = Forum.find(params[:id])
    @topics = @forum.topics.paginate :include => [:user, :replied_by_user, :last_post], :page => params[:page], :per_page => 25 #TODO add to config
    @page_title = "Viewing Forum #{h @forum.name}"
    # keep track of when we last viewed this forum for activity indicators
    (session[:forums] ||= {})[@forum.id] = Time.now.utc if logged_in?
  end

end