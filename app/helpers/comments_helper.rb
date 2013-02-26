module CommentsHelper

  def comment_owner_class(comment, css_class = 'owner')
    comment.user_id == comment.commentable.user_id ? css_class : ''
  end

  def comment_to_controller(comment)
    #TODO redo this using routes
    comment_link = "#{comment.commentable_id}#comment-#{comment.id}"
    case comment.commentable_type
      when 'Article'; return "/articles/view/#{comment_link}"
      when 'Blog';  return "/blogs/show/#{comment_link}"
    end
  end  

end