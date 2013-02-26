class Admin::CategoryNewsController < Admin::AdminController

   active_scaffold :category_news do |config|
    config.label = "News Categorie"
    #columns
    config.columns['parent'].form_ui = :select

    config.list.columns    = [:category, :children]
    config.create.columns  = [:category, :parent]
    config.update.columns  = [:category, :parent]
  end

end
