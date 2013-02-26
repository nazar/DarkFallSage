class UserMailer < ActionMailer::Base

  include ActionController::UrlWriter
#  default_url_options[:host] = 'darkfallsage.com'

  def self.set_home_from_request(request)
    default_url_options[:host] = "#{request.host_with_port}"
  end

  def welcome_email(user, password)
    setup_email(user)
    @subject << 'Welcome to  - Account Login Details - Important'
    @body[:password] = password
  end

  def activate_account(user)
    setup_email(user)
    @subject << 'Project Darkfall Account Activation - Important'
  end

  def notify_admins_signup(admins, new_user)
    set_email_header
    @subject    << 'New User Registration'
    @recipients = []; admins.each{|admin| @recipients << admin.email}
    @body[:user] = new_user
  end

  def notify_admin_obj_edited(admins, obj, link, diff, user)
    set_email_header
    @subject  << obj.class.to_s << ' - Edited by ' << user.login
    @recipients = []; admins.each{|admin| @recipients << admin.email}
    @body[:user] = user
    @body[:diff] = diff
    @body[:obj]  = obj
    @body[:link] = link
  end

  def notify_admin_obj_added(admins, obj, link, user)
    set_email_header
    @subject  << obj.class.to_s << ' - Added by '  << user.login
    @recipients = []; admins.each{|admin| @recipients << admin.email}
    @body[:user] = user
    @body[:link] = link
    @body[:obj]  = obj
  end

  def clan_application(user, clan, application)
    setup_email(clan.owner)
    @subject  << "Clan Application from #{user.name}"
    @body[:applicant] = user
  end

  def clan_application_accepted(application)
    setup_email(application.user)
    @subject  << "Clan #{application.clan.name} Application - Application Accepted"
    @body[:clan] = application.clan
  end

  def clan_application_rejected(application)
    setup_email(application.user)
    @subject  << "Clan #{application.clan.name} Application - Application Rejected"
    @body[:clan] = application.clan
    @body[:reason] = application.actioned_reason
  end

  def member_joined_clan(member, clan)
    setup_email(clan.owner)
    @subject  << "Clan - Member #{member.user.name} has join your Clan"
    @body[:owner]  = clan.owner
    @body[:member] = member.user
  end

  def send_clan_invitation(clan, invite, host)
    default_url_options[:host] = host #hax to pass host to url methods
    #
    setup_email(invite.invitee)
    @subject  << "Clan Inivitation - Clan #{clan.name} Has Sent you an Invitation"
    @body[:user]   = invite.invitee
    @body[:clan]   = clan
    @body[:accept] = clan_invite_accept_url(invite.token)
    @body[:reject] = clan_invite_reject_url(invite.token)
  end

  def clan_alliance_proposal(alliance, proposal, host)
    default_url_options[:host] = host #hax to pass host to url methods
    #
    setup_email(alliance.lead_clan.owner)
    @subject  << "Clan Alliance - Clan #{proposal.clan.name} Proposes to join #{alliance.name}"
    @body[:owner]     = alliance.lead_clan.owner
    @body[:alliance]  = alliance
    @body[:from_clan] = proposal.clan
    @body[:accept]    = alliance_clan_accept_url(proposal.token)
    @body[:reject]    = alliance_clan_reject_url(proposal.token)
  end

  def clan_alliance_accepted(proposal)
    setup_email(proposal.clan.owner)
    @subject  << "Clan Alliance Accepted"
    @body[:owner]     = proposal.clan.owner
    @body[:alliance]  = proposal.alliance
    @body[:from_clan] = proposal.alliance.lead_clan
  end

  def clan_alliance_rejected(proposal)
    setup_email(proposal.clan.owner)
    @subject  << "Clan Alliance Rejected"
    @body[:owner]     = proposal.clan.owner
    @body[:alliance]  = proposal.alliance
    @body[:from_clan] = proposal.alliance.lead_clan
  end

  def alliance_invite_to_clan(proposal, alliance, clan, host)
    default_url_options[:host] = host #hax to pass host to url methods
    #
    setup_email(clan.owner)
    @subject  << "Clan Alliance Invite"
    @body[:from_clan] = alliance.lead_clan
    @body[:owner]     = clan.owner
    @body[:alliance]  = alliance
    @body[:accept] = alliance_clan_invite_accept_url(proposal.token)
    @body[:reject] = alliance_clan_invite_reject_url(proposal.token)
  end

  protected

  def setup_email(user)
    set_email_header
    @recipients  = "#{user.email}"
    @body[:user] = user
  end

  def set_email_header
    @from        = "do_not_reply@darkfallsage.com"
    @subject     = "Darkfall Sage - "
    @sent_on     = Time.now
    @content_type = "text/html"
  end  

end
