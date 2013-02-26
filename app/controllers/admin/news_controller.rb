class Admin::NewsController < Admin::AdminController

  helper :categories

  active_scaffold :news do |config|
    config.label = "News"
   #columns
    config.list.columns   = [:title, :categories, :active, :comments_count, :reads_count, :created_at]
    config.columns[:news_categories].form_ui = :select
    #override for listing order
    edit_column = [:title, :news_body, :news_categories_override, :active, :commentable, :created_at]
    config.create.columns = edit_column
    config.update.columns = edit_column << [:user]
    #
    config.columns[:user].form_ui = :select
    config.columns[:categories].clear_link
  end

  def update
    news = News.find_by_id(params[:id])
    news.news_categories.clear
    news.categories = CategoryNews.find(params[:record][:news_categories_override]) unless params[:record][:news_categories_override].blank?
    #let AS do its thing
    super
  end

  protected

  #called by ActiveScaffold before a save
   def before_create_save(record)
     record.user = current_user
     record.categories = CategoryNews.find(params[:record][:news_categories_override]) unless params[:record][:news_categories_override].blank?
   end

end
