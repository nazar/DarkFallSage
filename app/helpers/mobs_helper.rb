module MobsHelper

  def render_mob_properties_by_type(mob_type)
    if mob_type == 1
      render :partial => 'mobs/form_mob'
    elsif mob_type == 2
      render :partial => 'mobs/form_npc'
    end
  end

  def mob_table_row(record, column, name = '', data_override = nil)
    unless record.send(column).blank?
      markaby do
        tr :class => cycle('odd', 'even') do
          td.item_header name.blank? ? column.humanize : name
          td.item_data   {data_override.nil? ? record.send(column) : data_override}
        end
      end
    end
  end

  def mobs_alphabetic_filter
    s_letters = 'A'..'Z'
    a_letters = Mob.mob_alphabet
    markaby do
      table :class => 'alphabet_filter', :cellpadding => 0, :cellspacing => 0  do
        tr do
          for letter in s_letters
            unless a_letters[letter].nil?
              td {link_to(letter, "/mobs/filter/#{letter}", :title => pluralize(a_letters[letter], 'Mob'))}
            else
              td {content_tag(:span, letter, :class => 'empty')}
            end
          end
        end
      end
    end
  end

  def render_mob_spell_weakness(weak_schools)
    weak_schools ||= []
    spell_ids = weak_schools.collect{|s| s.weakness_id}
    cbs = MobWeakness.spell_weaknesses.sort{|a,b|a.last<=>b.last}.inject([]) do |result, school|
      result << (check_box_tag("weak_spell[#{school.first}]", 0, spell_ids.include?(school.first), :id => "weak_spell_#{school.first}") + school.last)
    end
    cbs.insert(7, '<br/>')
    cbs.join('&nbsp;')
  end

  def render_mob_melee_weakness(weak_melles)
    cbs = []
    weak_melles ||= []
    melee_ids = weak_melles.collect{|s| s.weakness_id} || []
    MobWeakness.melee_types.sort{|a,b|a.last<=>b.last}.each do |melee|
      cbs << (check_box_tag("weak_melee[#{melee.first}]", 0, melee_ids.include?(melee.first), :id => "weak_melee_#{melee.first}") + melee.last.humanize)
    end
    cbs.join('&nbsp;')
  end

  def mob_action_links
    links = [link_to('Add mob', new_mob_path) + ' to database']
    links << (link_to('View un-approved', unapproved_mob_path) + ' mobs') if Moderator.db_moderator?(current_user)
    links.join('&nbsp;&nbsp;|&nbsp;&nbsp;')
  end


end
