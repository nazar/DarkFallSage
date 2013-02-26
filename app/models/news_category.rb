class NewsCategory < ActiveRecord::Base

  belongs_to :news
  belongs_to :category, :foreign_key => 'category_id', :conditions => ['type=?','CategoryNews'], :class_name => 'CategoryNews'

  after_create  :inc_news_counts
  after_destroy :dec_news_counts

protected

  def inc_news_counts
    Category.increment_to_top(category)
  end

  def dec_news_counts
    Category.decrement_to_top(category)
  end


end