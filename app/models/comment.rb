class Comment < CommentBase

  #comment can only be edited by an admin or withing x mins if comment owner
  def can_edit(user)
    unless user.nil?
      user.admin? || ((user.id == user_id) && (updated_at < 5.minutes.ago)) #TODO add to Configuration class
    else
      false
    end
  end
  
end
