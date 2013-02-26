module SpellsHelper

  def spell_school_link(name, link = '')
    link = link.blank? ? "##{name.underscore.gsub(' ', '_')}" : link
    link_to(school_image(name), link) <<  '&nbsp;&nbsp;' << link_to(name, link)
  end

  def school_image(school_name)
    image_tag("spells/#{school_name.underscore.gsub(' ','_')}.jpg")
  end

  def spell_header_links(spell)
    spells = link_to('Spells', spells_path)
    type   = link_to(spell.spell_type_to_s, spell_by_type_path(spell.spell_type))
    school = @spell.school.blank? ? '' : ' - ' << link_to(spell.school.name, spell_by_school_path(spell.school_id))
    "#{type}#{school} - #{spells}"
  end

end
