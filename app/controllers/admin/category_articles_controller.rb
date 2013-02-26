class Admin::CategoryArticlesController < Admin::AdminController

  active_scaffold :category_articles do |config|
    config.label = "Article Categories Management"
    #columns
    config.columns['parent'].form_ui = :select
    
    config.list.columns    = [:category, :children]
    config.create.columns  = [:category, :parent]
    config.update.columns  = [:category, :parent]
  end
  

end
