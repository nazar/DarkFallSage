class DfVote < Vote

  after_create  :add_rating
  after_destroy :remove_rating


  private

  def add_rating
    adjust_rating
  end

  def remove_rating
    adjust_rating(-1)
  end

  def adjust_rating(bias = 1)
    if voteable && (voteable.respond_to?('rating'))
      rating = vote ? 1 : -1
      voteable.rating += (rating * bias)
      voteable.save
    end
  end


end