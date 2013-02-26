module AllianceClansHelper

  #produce accept/reject links if pending row is still pending
  def alliance_clans_action_column(pending)
    actions = []
    if pending.status == AllianceClan::StatusPending
      actions << link_to('accept', alliance_clan_accept_path(pending.token))
      actions << link_to('reject', alliance_clan_reject_path(pending.token))
    elsif pending.status = AllianceClan::StatusApproved
      actions << link_to('expel', alliance_clan_expel_path(pending.token), :confirm => "Expel this clan from the Alliance?")
    end
    actions.join('<br />')
  end

  def alliance_clans_invite_action_column(pending)
    actions = []
    if pending.status == AllianceClan::StatusInvited
      actions << link_to('accept', alliance_clan_invite_accept_path(pending.token))
      actions << link_to('reject', alliance_clan_invite_reject_path(pending.token))
    end
    actions.join('<br />')
  end

end
