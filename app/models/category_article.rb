#inherited from Category for use by Articles only using Rail's STI
class CategoryArticle < Category

  acts_as_tree

  has_many :article_categories, :foreign_key => 'category_id'
  has_many :articles, :through => :article_categories

  named_scope :top_level, :conditions => ['parent_id is null and type = ?', 'CategoryArticle'], :order => 'category ASC'


  def get_items
    articles
  end

end