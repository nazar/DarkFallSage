class ClanInvitesController < ApplicationController

  skip_before_filter :verify_authenticity_token, :only => [:non_members_list, :invite, :delete]

  before_filter :login_required, :only => [:non_members_list]


  def non_members_list
    @users = User.find :all, :conditions => ['login like ?', "#{params[:invite][:invitee]}%"]
    render :inline => "<%= content_tag(:ul, @users.map { |u| content_tag(:li, h(u.login)) }) %>"
  end

  def invite
    clan = Clan.find params[:id]
    can_admin_clan(clan, current_user) do
      invitee = User.find_by_login params[:invite][:invitee]
      if invitee && (not invitee.in_clan_or_owns_clan?)
        invite = ClanInvite.new_for_clan_invite(clan, invitee)
        UserMailer.deliver_send_clan_invitation(clan, invite, request.host)
      end
      redirect_to clan_path(clan)
    end
  end
  
  def accept
    invite = ClanInvite.find_by_token params[:token]
    unless invite.blank?
      if not invite.invitee.in_clan_or_owns_clan?
        ClanInvite.transaction do
          invite.response = ClanInvite::ResponseAccept
          invite.save
          #
          member = invite.clan.clan_members.create(:user_id => invite.invitee.id, :approved_at => Time.now)
          flash[:notice] = "You are now a member of #{invite.clan.name}"
          UserMailer.deliver_member_joined_clan(member, invite.clan)
          redirect_to clan_path(invite.clan)
        end
      else
        render :text => 'Invalid Request. Cannot be a member of more than one Clan', :layout => true
      end
    else
      render :text => 'Invalid Request', :layout => true
    end
  end
  
  def reject
    invite = ClanInvite.find_by_token params[:token]
    unless invite.blank?
      invite.response = ClanInvite::ResponseReject
      invite.save
      #
      flash[:notice] = "Invitation to #{invite.clan.name} rejected."
      redirect_to root_path
    else
      render :text => 'Invalid Request', :layout => true
    end
  end

  def delete
    invite = ClanInvite.find_by_id params[:id]
    can_admin_clan(invite.clan, current_user) do
      invite.destroy
      flash[:notice] = "Inivitation Deleted"
      redirect_to clan_path(invite.clan)
    end
  end

end
