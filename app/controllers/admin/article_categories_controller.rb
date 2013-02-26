class Admin::ArticleCategoriesController < Admin::AdminController

  active_scaffold :article_categories do |config|
    config.label = "  Categories Management"
  end

end
