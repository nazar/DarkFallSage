class ArticleCategory < ActiveRecord::Base

  belongs_to :article
  belongs_to :category, :foreign_key => 'category_id', :conditions => ['type=?','CategoryArticle'], :class_name => 'CategoryArticle'

  after_create  :inc_article_counts
  after_destroy :dec_article_counts

protected

  def inc_article_counts
    Category.increment_to_top(category)
  end

  def dec_article_counts
    Category.decrement_to_top(category)
  end


end