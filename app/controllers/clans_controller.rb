class ClansController < ApplicationController

  helper :markup, :alliances, :alliance_clans, :clan_forums

  before_filter :login_required, :only => [:new, :create, :edit, :update, :admin_clans, :admin_clan_forums_new,
                                           :apply, :join, :expel, :rank],
                :redirect_to => :login_path

  in_place_edit_for :clan_member, :rank


  def index
    @clans = Clan.all_by_name.paginate :include => :slugs, :page => params[:page], :per_page => 25 #TODO add to config
    @page_title = 'Viewing Clans'
  end

  def new
    is_reputable_to do
      #cannot create clan if already own one or are a member of a clan
      can_create_or_join_clan(current_user) do
        @clan = Clan.new
      end
    end
  end

  def create
    is_reputable_to do
      #cannot create clan if already own one or are a member of a clan
      can_create_or_join_clan(current_user) do
        @clan = Clan.new(params[:clan])
        @clan.members_count = 1
        @clan.owner = current_user
        if @clan.save
          redirect_to clan_path(@clan)
        else
          render :action => :new
        end  
      end
    end
  end

  def update
    @clan = Clan.find params[:id]
    can_admin_clan(@clan, current_user) do
      @clan.attributes = params[:clan]
      if @clan.save
        redirect_to clan_path(@clan)
      else
        render :action => :edit
      end
    end
  end

  def destroy
  end

  def edit
    @clan = Clan.find params[:id]
    can_admin_clan(@clan, current_user) do
      #continue
    end
  end

  def show
    @clan          = Clan.find params[:id]     #TODO need to optimise the includes
    @clan_forums   = ClanForum.clan_forums_by_acl(@clan, current_user).all :include => [:slugs]
    @clan_members  = @clan.clan_members :order => 'name'
    @can_join      = @clan.can_join?(current_user) || (current_user.blank?)
    @clan_images   = @clan.images.paginate :order => 'created_at DESC', :page => params[:page], :per_page => 20 #TODO param this
    @applications  = @clan.clan_applications.pending.not_rejected.all
    @invites       = @clan.clan_invites.pending #members invites to join clan
    @in_alliances  = @clan.alliances :include => [{:clan => :slugs}, :slugs, :lead_clan], :order => 'alliances.name'
    @own_alliances = @clan.owned_alliances :include => [{:clan => :slugs}, :slugs], :order => 'alliances.name'
    @clan_invites  = @clan.alliance_clans.invited.all :include => [{:alliance => :lead_clan}, :clan] #clans inviting @clan to an alliance
    @pending       = @clan.alliance_requests.pending :include => [{:clans => :slugs}, {:alliances => :slugs}]
    @view_invites  = (@clan.access_type == Clan::ByInvitation) && @clan.user_is_member?(current_user)
    @page_title    = "#{@clan.name} - Viewing Clan"
  end

  def apply
    clan = Clan.find params[:id]
    user_not_already_applied(current_user, clan) do
      unless params[:application].blank?
        application = clan.clan_applications.create(:user_id => current_user.id, :application => params[:application][:application], :status => 1)
        UserMailer.deliver_clan_application(current_user, clan, application)
        flash[:success] = "Application sent to clan #{clan.name} leader."
      end
      redirect_to clan_path(clan)
    end
  end

  def join
    clan = Clan.find params[:id]
    user_not_already_applied(current_user, clan) do
      if clan.access_type == Clan::OpenToAll #can only join if access_type = 2
        Clan.transaction do
          clan_member = clan.clan_members.create(:user_id => current_user.id)
          UserMailer.deliver_member_joined_clan(clan_member, clan)
        end
        redirect_to clan_path(clan)
      else
        render :text => 'Invalid Request', :layout => true
      end
    end
  end

  def expel
    clan = Clan.find params[:clan_id]
    can_admin_clan(clan, current_user) do
      member = ClanMember.find_by_id params[:member_id]
      Clan.transaction do
        member.destroy
        redirect_to clan_path(clan)
      end
    end
  end

  def rank
    @clan = Clan.find params[:clan_id]
    can_admin_clan(@clan, current_user) do
      @member = ClanMember.find params[:member_id]
      return unless request.post?
      @member.rank = params[:member][:rank]
      @member.save
      #
      redirect_to clan_path(@clan)
    end  
  end

  protected

  #checks whether supplier user owns a clan or is a member of a clan
  def can_create_or_join_clan(user)
    raise "must supply a block" unless block_given?
    unless user.clans.blank? && user.member_of_clan.blank?
      render :partial => 'clans/cannot_create_or_join', :layout => true
    else
      yield
    end
  end

  def user_not_already_applied(user, clan)
    unless clan.already_applied?(user)
      yield
    else
      render :partial => 'clan_applications/already_applied', :layout => true
    end
  end

end
