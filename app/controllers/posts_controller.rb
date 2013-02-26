class PostsController < ApplicationController

  helper :markup 

  before_filter :login_required, :redirect_to => :login_path 

  #shows the reply form
  def reply
    is_reputable_to do
      @post  = Post.find(params[:id])
      @topic = @post.topic
      @topicable = @topic.topicable
      #
      render_reply_form
    end  
  end

  def quote
    @post  = Post.find(params[:id])
    @topic = @post.topic
    @topic.body = @post.quote_body 
    @topicable = @topic.topicable
    #
    render_reply_form
  end
  
  def edit
    @post  = Post.find(params[:id])
    @topic = @post.topic
    @topic.body = @post.body 
    @topicable = @topic.topicable
  end
  
  def delete
    @post  = Post.find(params[:id])
    topic  = @post.topic
    #only an admin can delete a post
    if current_user and current_user.admin?
      @post.destroy
    end 
    redirect_to topic_path(topic)
  end

  def by_user
    @user = User.find_by_login params[:login]
    @posts = @user.posts.not_clans.paginate :order => 'posts.created_at DESC', :include => [:topic, :user],
                                  :page => params[:page], :per_page => 20 #TODO configu option
  end

  protected

  def render_reply_form
    respond_to do |format|
      format.html {}
      format.js   {render :partial => 'posts/ajax_reply_form', :locals => {:forum => @topicable, :topic => @topic, :post => @post} }
    end
  end
 
end
