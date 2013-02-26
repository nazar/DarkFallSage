class Admin::ForumsController < Admin::AdminController

  active_scaffold :forums do |config|
    config.label = "Forums"
    #column
    update_columns = [:name, :description, :position]
    config.list.columns = [:name, :description, :position, :posts_count, :topics_count, :created_at, :last_posted]
    config.create.columns = config.update.columns = update_columns
  end


end
