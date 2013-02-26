class Admin::VotesController < Admin::AdminController

  active_scaffold :votes do |config|
    config.label = "Votes"
  end

end
