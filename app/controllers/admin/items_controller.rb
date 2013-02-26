class Admin::ItemsController < Admin::AdminController

  active_scaffold :items do |config|
    config.label = "Item"
  end

end
