module ImagesHelper

  def render_image_breadcrumb(image)
    link = nil
    link = case image.imageable_type
      when 'Item' then link_to 'Items', items_path
      when 'Skill' then link_to 'Skills', skills_path
      when 'Spell' then link_to 'Spells', spells_path
      when 'Mob' then link_to('Mobs', mobs_path)
      when 'Poi' then link_to 'Points of Interest', pois_path
      when 'Clan' then link_to 'Clan', clans_path
    end
     return link << ' > ' << link_to(image.imageable.name.humanize, polymorphic_path(image.imageable))
  end

end
