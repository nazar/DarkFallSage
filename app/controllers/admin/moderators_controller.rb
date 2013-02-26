class Admin::ModeratorsController < Admin::AdminController

  active_scaffold :moderators do |config|
    config.label = "Moderators"
    #columns
    config.columns[:user].form_ui = :select
  end
  
end
