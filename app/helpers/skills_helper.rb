module SkillsHelper

  def skill_link_and_type_link(skill)
    skills = link_to('Skills', skills_path)
    type = link_to(skill.skill_type_to_s, skill_by_type_path(skill.skill_type))
    "#{type} - #{skills}"
  end

end
