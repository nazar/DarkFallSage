class AlliancesController < ApplicationController

  helper :markup, :alliance_clans

  before_filter :login_required, :only => [:new, :create, :edit, :update, :destroy, :join, :leave, 
                                           :invite, :new_and_invite],
                :redirect_to => :login_path

  def index
    
  end
  
  def show
    @alliance       = Alliance.find params[:id]
    @alliance_clans = @alliance.alliance_clans.with_clans.all :order => 'clans.name'
    @logs           = @alliance.alliance_logs :order => 'created_at DESC'
    @can_admin      = @alliance.lead_clan.can_admin?(current_user)
    @page_title     = "#{h @alliance.name} - Viewing Alliance Details"
  end
  
  def new
    @clan = Clan.find params[:clan_id]
    can_admin_clan(@clan, current_user) do
      @alliance = @clan.owned_alliances.new
    end  
  end

  def create
    @alliance = Alliance.new(params[:alliance])
    clan     = @alliance.lead_clan
    can_admin_clan(clan, current_user) do
      if @alliance.save
        redirect_to clan_path(clan)
      else
        render :action => :new
      end
    end
  end
  
  def join
    alliance = Alliance.find params[:id]
    unless current_user.clans.blank?
      joining_clan = current_user.clans.first
      Alliance.transaction do
        alliance_clan = AllianceClan.new_for_alliance_clan(alliance, joining_clan)
        alliance_clan.save
        link = with_helpers{link_to(h(joining_clan.name), clan_path(joining_clan))}
        AllianceLog.log_event("#{link} applied to join the Alliance", alliance, joining_clan)
        UserMailer.deliver_clan_alliance_proposal(alliance, alliance_clan, request.host)
        #
        redirect_to clan_path(alliance.lead_clan)
      end  
    else
      render :text => 'Only clan owners can join alliances', :layout => true
    end
  end

  def leave
    alliance = Alliance.find params[:id]
    clan     = current_user.clans.first
    unless clan.blank?
      alliance_clan = alliance.alliance_clans.find_by_clan_id clan.id
      if alliance_clan
        Clan.transaction do
          alliance_clan.destroy
          AllianceLog.log_event("Clan #{h clan.name} has left the alliance", alliance, clan)
          redirect_to clan_path(clan)
        end
      end
    else
      redirect_to root_path
    end
  end

  #:alliance can either be specific alliance or -1.. if -1 then show a form and pick alliance
  def invite
    @invite   = Clan.find params[:invite_clan]
    @alliance = Alliance.find params[:alliance]
    can_admin_clan(@alliance.lead_clan, current_user) do
      Alliance.transaction do
        invite_clan_to_alliance(@invite, @alliance)
        #
        flash[:notice] = "Alliance invitation sent to #{@invite.name}"
        redirect_to clan_path(@invite)
      end  
    end
  end

  def new_and_invite
    @clan    = Clan.find params[:my_clan]
    @invite  = Clan.find params[:invite_clan]
    can_admin_clan(@clan, current_user) do
      @alliance = @clan.owned_alliances.new
      return unless request.post?
      #return from form post
      Alliance.transaction do
        @alliance = Alliance.new(params[:alliance])
        if @alliance.save
          #alliance if ok... now invite
          invite_clan_to_alliance(@invite, @alliance)
          #
          flash[:notice] = "Alliance invitation sent to #{@invite.name}"
          redirect_to clan_path(@clan)
        else
          render :action => :new_and_invite
        end
      end  
    end
  end

  protected

  def invite_clan_to_alliance(clan, alliance)
    alliance_clan = AllianceClan.new_for_alliance_clan(alliance, clan)
    alliance_clan.status = AllianceClan::StatusInvited
    alliance_clan.save
    link = with_helpers{link_to(h(clan.name), clan_path(clan))}
    AllianceLog.log_event("#{link} invited to join the Alliance", alliance, clan)
    UserMailer.deliver_alliance_invite_to_clan(alliance_clan, alliance, clan, request.host)
  end

end