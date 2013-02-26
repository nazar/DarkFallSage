class Admin::UsersController < Admin::AdminController

  active_scaffold :users do |config|
    config.label = "Registered Users"
    #remove default action links
    config.actions = [:list, :search, :update, :show, :nested, :subform]
    #columns
    config.list.columns   = [:id, :login, :name, :admin, :email, :activated, :created_at]
    config.show.columns   = [:id, :login, :name, :email, :admin ]
    config.update.columns = [:name, :email, :admin, :active]
  end 

end
