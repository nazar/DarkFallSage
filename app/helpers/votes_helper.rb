module VotesHelper

  def upvote_class(voted)
    result = voted ? ' on' : ''
    "upcount#{result}"
  end

  def downvote_class(voted)
    result = voted ? ' on' : ''
    "downcount#{result}"
  end

end
