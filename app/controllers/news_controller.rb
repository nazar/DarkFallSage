class NewsController < ApplicationController

  def index
    @news = News.by_date.all :limit => 20, :include => [:user, :slugs, :categories]
    @page_title = 'Darkfall Sage News'
  end

  def show
    @news = News.find params[:id]
    @topics = @news.topics.paginate :include => [:user, :replied_by_user, :last_post],
                                    :page => params[:page], :per_page => 25 #TODO add to config
    @page_title = "#{@news.title} - Reading News Article"
  end

  def by_category
    cat = CategoryNews.find_by_id(params[:id])
    @page_title = "Category #{cat.category} - Viewing News Articles in Section"
    @news = cat.news :order => 'created_at DESC'
    render :action => :index
  end

end
