class IrcController < ApplicationController

  def index
    @nick = logged_in? ? "darkfallsage_#{current_user.login}" : 'darkfallsage_guest_' << String.random_string(3)
    @page_title = 'Darkfall Sage IRC Web Client'
  end

end
