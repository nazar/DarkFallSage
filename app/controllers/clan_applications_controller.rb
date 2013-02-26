class ClanApplicationsController < ApplicationController

  helper :markup

  before_filter :login_required, :only => [:accept, :reject, :show],
                :redirect_to => :login_path

  def accept
    app = ClanApplication.find params[:id]
    can_process_application(app) do
      Clan.transaction do
        app.clan.clan_members.create(:user_id => app.user_id, :approved_by => current_user.id,
                                     :approved_at => Time.now, :application => app.application,
                                     :rank => 10)
        #update application
        app.status = 2 #approved
        app.actioned_by = current_user.id
        app.actioned_at = Time.now
        app.save
        #notify applier
        UserMailer.deliver_clan_application_accepted(app)
        #
        redirect_to clan_path(app.clan)
      end  
    end
  end

  def reject
    @application = ClanApplication.find params[:id]
    can_process_application(@application) do
      return unless request.post?
      @application.errors.add(:actioned_reason, 'Must supply a rejection reason') if params[:application][:actioned_reason].blank?
      if @application.errors.blank?
        Clan.transaction do
          @application.status = 3 #rejected
          @application.actioned_by = current_user.id
          @application.actioned_reason = params[:application][:actioned_reason]
          @application.actioned_at = Time.now
          @application.save
          #notify applier
          UserMailer.deliver_clan_application_rejected(@application)
          #done....go back to clan page
          redirect_to clan_path(@application.clan)
        end
      else
        render :action => :reject
      end
    end
  end

  protected

  #checks whether current user can admin and validity of club and application
  def can_process_application(application)
    clan = application.clan
    raise "block must be supplied" unless block_given?
    if (clan.access_type == 1) && clan.can_admin?(current_user) && clan.already_applied?(application.user)
      yield
    else
      render :text => 'Invalid or un-authorised request', :layout => true
    end
  end

end
