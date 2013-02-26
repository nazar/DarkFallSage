module AlliancesHelper

  def alliance_clan_user_actions(alliance, clan, user)
    actions = []
    if clan.can_admin?(user) && (alliance.clan_owner_id != clan.id) 
      actions << link_to('leave', alliance_leave_path(alliance), :confirm => 'Leave this Alliance?')
    end  
    #can delete clan if user is clan owner and this alliance belongs to my clan and there are no clans in the alliance
    if clan.can_admin?(user) && (alliance.clans_count == 1) && (alliance.clan_owner_id == clan.id)
      actions << link_to('delete', alliance_delete_path(alliance), :confirm => 'Delete this Alliance?')
    end
    #can join this alliance if user owns a clan.. and that clan is not this clan
    if user && (not user.clans.blank?) && (user.clans.first.id != clan.id) && (not user.my_alliance_ids.include?(alliance.id))
      actions << link_to('join', alliance_join_path(alliance), :confirm => 'Join this Alliance?')
    end
    actions.join('<br />')
  end

end
