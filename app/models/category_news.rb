#inherited from Category for use by Articles only using Rail's STI
#All categories created through this class will have type CategoryNews
class CategoryNews < Category

  acts_as_tree

  has_many :news_categories, :foreign_key => 'category_id'
  has_many :news, :through => :news_categories

  named_scope :top_level, :conditions => ['parent_id is null and type = ?', 'CategoryNews'], :order => 'category ASC'


  def get_items
    news
  end

end