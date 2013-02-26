class ClanForumsController < ApplicationController

  helper :markup

  before_filter :login_required, :only => [:new, :create, :edit, :update, :admin],
                :redirect_to => :login_path

  def index

  end

  def admin
    @clan = Clan.find params[:clan_id]
    can_admin_clan(@clan, current_user) do
      @forums     = @clan.clan_forums.ordered.all :include => :slugs
      @page_title = "#{@clan.name} - Forum Administration"
    end
  end

  def new
    @clan = Clan.find params[:clan_id]
    can_admin_clan(@clan, current_user) do
      @forum      = @clan.clan_forums.build(:access_type => 0)
      @page_title = "#{@clan.name} - Forum Administration"
    end
  end

  def create
    @clan = Clan.find params[:clan_id]
    can_admin_clan(@clan, current_user) do
      @forum      = @clan.clan_forums.build(params[:forum])
      if @forum.save
        redirect_to clan_forums_admin_path(@clan)
      else
        render :action => :new
      end
    end
  end

  def edit
    @forum = ClanForum.find params[:forum_id]
    clan   = @forum.clan
    can_admin_clan(clan, current_user) do
      #continue
    end
  end

  def update
    @forum = ClanForum.find params[:forum_id]
    clan   = @forum.clan
    can_admin_clan(clan, current_user) do
      @forum.attributes = params[:forum]
      if @forum.save
        redirect_to clan_forums_admin_path(clan)
      else
        render :action => :edit
      end
    end
  end

  def destroy
    @forum = ClanForum.find params[:forum_id]
    clan   = @forum.clan
    can_admin_clan(clan, current_user) do
      @forum.destroy
      redirect_to clan_forums_admin_path(clan)
    end
  end

  def show
    @forum  = ClanForum.find params[:forum_id] 
    @clan   = @forum.clan
    @topics = @forum.topics.all_includes.paginate :per_page => 25, :page => params[:page] #TODO setup class
    #must check if current user has access to this forum
    render :partial => 'clan_forums/no_access', :layout => true unless @forum.user_can_access?(current_user)
  end

end
