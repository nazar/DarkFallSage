class  SkillSweeper < ActionController::Caching::Sweeper

  observe Skill 

  def after_create(skill)
    expire_cache_for(skill)
  end

  def after_update(skill)
    expire_cache_for(skill)
  end

  def after_destroy(skill)
    expire_cache_for(skill)
  end

  private

  def expire_cache_for(record)
    expire_action(:controller => 'skills', :action => 'index')
  end
  

end