class TopicsController < ApplicationController
  
  helper :markup, :forums, :votes

  verify :method => :post, :only => [ :create, :reply ]

  before_filter :login_required, :only => [:new, :create, :edit, :update, :destroy, :reply]

  def new
    is_reputable_to do
      @topicable = find_topicable
      topicable_can_access(@topicable, current_user) do
        @topic     = @topicable.topics.build
        @post      = Post.new
        respond_to do |format|
          format.html{}
          format.js  {render :partial => 'posts/ajax_post_form', :locals => {:forum => @topicable, :topic => @topic, :post => @post} }
        end
      end  
    end  
  end
  
  def show
    @topic      = Topic.find(params[:id])
    @topicable  = @topic.topicable
    topicable_can_access(@topicable, current_user) do
      @last_post  = @topic.posts.last
      @page_title = "#{h @topic.title} - Viewing Topic"
      @can_admin  = admin? || (@topicable.respond_to?('can_admin?') && @topicable.can_admin?(current_user))
      @can_reply  = (@topic.locked.to_i == 0) || @can_admin

      @topic.hit! unless logged_in? and @topic.user == current_user
      @posts = @topic.posts.good.paginate :page => params[:page], :per_page => 20, #Configuration.forum_posts_per_page,
                                     :order => 'posts.created_at', :include => [{:user => :counter}, :votes]#,
      if @posts.length == 0
        render :text => '<h3>No posts were found in this topic. H@x0r @t3mpt?</h3>', :layout => true
      end
    end  
  end

  def next
    topic      = Topic.find(params[:id])
    next_topic = Topic.next_topic(topic)
    if next_topic
      redirect_to topic_path(next_topic)
    else
      redirect_to topic_path(topic)
    end   
  end
  
  def previous
    topic      = Topic.find(params[:id])
    next_topic = Topic.prev_topic(topic)
    if next_topic
      redirect_to topic_path(next_topic)
    else
      redirect_to topic_path(topic)
    end   
  end

  #When viewing topics list,  creates a new topic and the first post in that topic.
  #When viewing posts in a topic, creates a new topic and the first post in that.
  #In both instances, a redirect is peformed to the new topic and post (html and js)
  def create
    @topicable = find_topicable
    topicable_can_access(@topicable, current_user) do
      unless params[:post].blank?
        @topic, @post = Topic.create_topic_and_post_from_params(params[:topic], @topicable, current_user, request.remote_ip)
        if (@topic.errors.length > 0) || ( @post && (@post.errors.length > 0)  )
          render :action => :new
        else
          redirect_to topic_path(@topic)
        end
      else #cancel
        respond_to do |format|
          format.html { redirect_to topic_path(params[:id]) }
          format.js   { render :nothing => true }
        end
      end
    end  
  end
  
  #topic reply
  def reply
    is_reputable_to do
      @topic = Topic.find(params[:id])
      if (not @topic.locked.to_i == 1) || admin?
        #possibly editing... check permissions..ie only owner or admin can edit
        if params[:edit] && params[:edit].to_i> 0
          post = Post.find(params[:edit])
          if current_user && ((current_user.admin) || (post.user_id == current_user.id))
            @post = post
            @post.update_attributes(params[:topic])
          end
        end
        @topic.locked = params[:topic][:locked]
        @topic.sticky = params[:topic][:sticky]
        @topic.save
        #if not editing then create
        if !@post
          @post  = @topic.posts.build(params[:topic])
        end
        #save if the post has a body
        unless @post.body.blank?
          Topic.transaction do
            if (@topic.title != @post.title)
              if (@post.title)
                @topic.title = @post.title
                @topic.save!
              else
                @post.title = @topic.title
              end
            end
            @post.user = current_user
            @post.ip = request.remote_ip
            @post.save!
          end
          #
          redirect_to topic_path(@topic).to_s + "#post#{@post.id}"
        else
          redirect_to topic_path(@topic)
        end
      else
        render :text => 'topic locked!', :layout => true
      end
    end  
  end

  def by_user
    @user = User.find_by_login params[:login]
    @topics = @user.topics.and_public_clans.all_includes.paginate :order => 'topics.replied_at DESC',
                                    :page => params[:page], :per_page => 20 #TODO configu option
  end

protected

  def find_topicable
    params[:topicable_type].constantize.find(params[:topicable_id])
  end
  
end
