class Admin::AbilitiesController < Admin::AdminController

  active_scaffold :abilities do |config|
    config.label = "Ability"
    config.list.columns = [:name]
    config.update.columns = config.create.columns = [:name, :description]
  end

end
