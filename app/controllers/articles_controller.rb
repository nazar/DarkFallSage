class ArticlesController < ApplicationController

  helper :categories, :markup, :comments

  def index
    @top_level = CategoryArticle.top_level
    @page_title = 'Articles - Darkfall Sage'
    ##
    @latest_articles = Article.all :limit => 15, :order => 'created_at DESC'
  end

  def view
    @article = Article.find(params[:id])
    @article.reads_count += 1
    @article.save
    @topics = @article.topics.paginate :include => [:user, :replied_by_user, :last_post],
                                       :page => params[:page], :per_page => 25 #TODO add to config
    @page_title = "#{h @article.title} - Darkfall Sage Article"
  end

  def list
    @category = CategoryArticle.find_by_id(params[:id])
    @articles = @category.all_items_in_tree.uniq
    @page_title = "#{@category.category} Articles"
  end

end
