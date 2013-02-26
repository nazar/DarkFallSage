module ClansHelper

  def servers_select_options
    Clan.servers.sort{|a,b|a[1]<=>b[1]}.collect{|i|[i.last, i.first]}
  end

  def access_type_select_options
    Clan.access_types.sort{|a,b|a[1]<=>b[1]}.collect{|i|[i.last, i.first]}
  end

  def clan_table_row(record, column, name = '', data_override = nil)
    unless record.send(column).blank?
      markaby do
        tr :class => cycle('odd', 'even') do
          td.item_header name.blank? ? column.humanize : name
          td.item_data   {data_override.nil? ? record.send(column) : data_override}
        end
      end
    end
  end

  def alliance_link_actions(clan, can_admin)
    actions = []
    unless current_user.blank?
      if can_admin #clan admin
        actions << (link_to('Create', clan_alliance_new_path(clan)) + ' a new Alliance')
      elsif clan.owned_alliances.length == 0 #next section valid only if clan has no alliances... offer to create alliances  
        if current_user.clans.length > 0 #user is a clan owner... but not of this clan... invite options
          #user's clan has at least one alliance
          if current_user.clans.first.owned_alliances.length > 0
            unless current_user.my_allied_clan_ids.include?(clan.id) #this clan not part of one of current_user's alliance
              if current_user.clans.first.owned_alliances.length == 1 #only one alliance... invite to this one
                alliance = current_user.clans.first.owned_alliances.first
                actions << content_tag(:strong, link_to('Invite', clan_alliance_invite_path(clan, alliance))) +
                           " to join your #{link_to alliance.name, alliance_path(alliance)} Alliance."
              else #more than one alliance... don't name a specific alliance
                actions << render(:partial => 'alliances/invite_clan_form', :locals => {:invite_clan => clan, :my_clan => current_user.clans.first})
              end
            else
              actions << 'This is an allied clan'
            end
          else #clan owner but no alliances in own clan... option to create an alliance then invite this clan
            user_clan = current_user.clans.first
            actions << "Your clan #{content_tag(:strong, user_clan.name)} has no alliances. " +
                       link_to('Create an Alliance', clan_alliance_create_invite_path(user_clan, clan)) +
                       " and invite #{content_tag(:strong, clan.name)} to join."
          end
        end
      end
    end
    actions.join('<br />') #TODO actions appear to be exclusive..need join?
  end


end
