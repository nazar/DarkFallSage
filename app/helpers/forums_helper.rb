module ForumsHelper

  def can_edit_post(post_obj)
    current_user && (current_user.admin || ((current_user.id == post_obj.user_id) && (post_obj.created_at + 60.minute > Time.now) ) ) #TODO 60 mins in Configuration
  end

  #can vote unless own post or posted by admin
  def can_post_vote(post)
    if current_user.blank?
      true && (!post.user.admin?) #show vote block unless posted by an admin
    else
      (!post.user.admin?) && (post.user_id != current_user.id)
    end
  end

end