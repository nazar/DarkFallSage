class AbilitiesController < ApplicationController

#  before_filter :login_required, :only => [:new, :create, :edit, :update, :destroy],
#          :redirect_to => :login_path

  def show
    @ability = Ability.find params[:id]
    @topics = @ability.topics.paginate :include => [:user, :replied_by_user, :last_post],
                                       :page => params[:page], :per_page => 25 #TODO add to config
    @page_title = "#{@ability.name} Information"
  end

end
