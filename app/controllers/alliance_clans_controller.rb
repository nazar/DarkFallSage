class AllianceClansController < ApplicationController

  def accept
    proposal = AllianceClan.find_by_token params[:token]
    if proposal && proposal.status == AllianceClan::StatusPending
      Clan.transaction do
        proposal.status = AllianceClan::StatusApproved
        proposal.save
        #
        link = with_helpers{link_to(h(proposal.clan.name), clan_path(proposal.clan))}
        AllianceLog.log_event("Clan #{link} approved to join alliance", proposal.alliance, proposal.clan)
        UserMailer.deliver_clan_alliance_accepted(proposal)
        #
        flash[:notice] = 'Alliance Proposal Approved.'
        redirect_to clan_path(proposal.alliance.lead_clan)
      end
    else
      render :text => 'Invalid Requesr.', :layout => true
    end
  end

  def reject
    proposal = AllianceClan.find_by_token params[:token]
    if proposal && proposal.status == AllianceClan::StatusPending
      proposal.status = AllianceClan::StatusRejected
      proposal.save
      #
      link = with_helpers{link_to(h(proposal.clan.name), clan_path(proposal.clan))}
      AllianceLog.log_event("Clan #{link} to join alliance was rejected", proposal.alliance, proposal.clan)
      UserMailer.deliver_clan_alliance_rejected(proposal)
      #
      flash[:notice] = 'Alliance Proposal Rejected.'
      redirect_to clan_path(proposal.alliance.lead_clan)
    else
      render :text => 'Invalid Requesr.', :layout => true
    end
  end

  def expel
    proposal = AllianceClan.find_by_token params[:token]
    if proposal && proposal.status == AllianceClan::StatusApproved
      Clan.transaction do
        link = with_helpers{link_to(h(proposal.clan.name), clan_path(proposal.clan))}
        AllianceLog.log_event("Clan #{link} was expelled from Alliance", proposal.alliance, proposal.clan)
        proposal.destroy
        flash[:notice] = 'Clan expelled from Alliance'
        redirect_to alliances_path(proposal)
      end
    end
  end

  def invite_accept
    proposal = AllianceClan.find_by_token params[:token]
    if proposal && proposal.status == AllianceClan::StatusInvited
      save_clan_proposal_result(proposal.clan, proposal, AllianceClan::StatusApproved, 'accepted')
      flash[:notice] = 'Clan Alliance Accepted.'
      redirect_to clan_path(proposal.clan)
    else
      render :text => 'Invalid Request', :layout => true
    end
  end

  def invite_reject
    proposal = AllianceClan.find_by_token params[:token]
    if proposal && proposal.status == AllianceClan::StatusInvited
      save_clan_proposal_result(proposal.clan, proposal, AllianceClan::StatusRejected)
      flash[:notice] = 'Clan Alliance Rejected.'
      redirect_to clan_path(proposal.clan)
    else
      render :text => 'Invalid Request', :layout => true
    end
  end

  protected

  def save_clan_proposal_result(clan, proposal, status, action = nil)
    action ||= AllianceClan.statuses[status]
    proposal.status = status
    proposal.save
    #
    link = with_helpers{link_to(h(clan.name), clan_path(clan))}
    AllianceLog.log_event("Clan #{link} #{action} alliance invitation", proposal.alliance, clan)
  end

end
