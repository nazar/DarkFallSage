class CommentsController < ApplicationController
  
  helper :markup
  
  verify :method => :post, :only => [ :add_comment, :update ]
  before_filter :login_required, :except => [:add_comment]

  def add_comment
    #only logged in members can register
    return if current_user.nil? 
    #safe to continue
    commentable_type = params[:commentable][:commentable]
    commentable_id   = params[:commentable][:commentable_id]
    # Get the object that you want to comment
    commentable = Comment.find_commentable(commentable_type, commentable_id)
    # Create a comment with the user submitted content
    comment = Comment.new(params[:comment])
    Comment.transaction do
      # Assign this comment to the logged in user
      comment.user_id = current_user ? current_user.id : 0
      comment.ip      = request.remote_ip
      comment.commentable_type = commentable_type
      comment.commentable_id   = commentable_id
      comment.user_id = current_user ? current_user.id : 0
      #spam check only for anon users for the time being
      #increment user post count - this is not the same as comments count, which is incremented by Comment on save
      if current_user
        current_user.increment_posts_count
      end
      #save comment and observer kicks in here
      comment.save!
    end
    respond_to do |format|
      format.html {redirect_to comment_view_link(comment, :anchor => true)}
      format.js   {render :partial => 'comments/comment_row', :locals => {:comment => comment, :commentable => commentable}}
    end
    #TODO finally... send notification
  end

  def edit
    @comment = Comment.find_by_id(params[:id])
    if @comment.can_edit(current_user)
      respond_to do |format|
        format.html {redirect_to comment_view_link(@comment, :anchor => true)} #edit only using js
        format.js   {render :partial => 'comments/update_comment', :locals => {:model => @comment.commentable}}
      end
    else
      render :text => 'invalid request'
    end
  end

  def update
    @comment = Comment.find_by_id params[:id]
    if params[:save_comment] && @comment.can_edit(current_user)
      @comment.title = params[:comment][:title]
      @comment.body  = params[:comment][:body]
      @comment.ip    = request.remote_ip;
      @comment.save!
    end
    respond_to do |format|
      format.js   {render :partial => 'comments/comment_row', :locals => {:comment => @comment, :commentable => @comment.commentable}}
      format.html {redirect_to comment_view_link(@comment, :anchor => true)}
    end
  end

  def delete
    return unless admin?
    comment = Comment.find_by_id params[:id]
    comment.destroy;
    respond_to do |format|
      format.js   {render :nothing => true, :status => 200}
      format.html {redirect_to(comment_view_link(comment)) }
    end
  end

  def delete_comment
    comment     = Comment.find(params[:id])
    commentable = Comment.find_commentable(params[:commentable], params[:commentable_id])
    #decrement count for host object
    Comment.transaction do
      commentable.comments_count -= 1 if commentable.comments_count > 0
      commentable.save
      #remove from page
      render :update do |page|
        page.remove("comment_row_#{comment.id}")
      end
      #destroy
      comment.destroy
    end
  end
    
  protected

  def comment_view_link(comment, options={})
    commentable    = comment.get_commentable
    commented_link = eval("#{commentable.class.to_s.downcase}_view_link_url(:id => commentable.id)")
    commented_link = "#{commented_link}#comment-#{comment.id}" unless options[:anchor].blank?
    commented_link
  end
    

end
