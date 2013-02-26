class Admin::ArticlesController < Admin::AdminController

  helper :categories
    
  active_scaffold :articles do |config|
    config.label = "Articles"
    config.columns[:article_categories].form_ui = :select
    #override for listing order
    config.list.columns   = [:title, :categories, :active, :up_count, :down_count, :comments_count, :bookmarks_count, :reads_count, :created_at]

    edit_column = [:title, :body, :article_tags, :categories, :active, :bookmarkable, :rateable, :commentable]
    config.create.columns = edit_column
    config.update.columns = edit_column << [:user]
    #
    config.columns[:user].form_ui = :select
    config.columns[:categories].clear_link
  end

  def update
    article = Article.find_by_id(params[:id])
    article.article_categories.clear
    article.categories = CategoryArticle.find(params[:record][:categories]) unless params[:record][:categories].blank?
    #let AS do its thing
    super
  end

  protected

  #called by ActiveScaffold before a save
   def before_create_save(record)
     record.user = current_user
     record.categories = CategoryArticle.find(params[:record][:categories]) unless params[:record][:categories].blank?
   end

end
