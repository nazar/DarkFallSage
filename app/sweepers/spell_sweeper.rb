class  SpellSweeper < ActionController::Caching::Sweeper

  observe Spell

  def after_create(spell)
    expire_cache_for(spell)
  end

  def after_update(spell)
    expire_cache_for(spell)
  end

  def after_destroy(spell)
    expire_cache_for(spell)
  end

  private

  def expire_cache_for(record)
    expire_action(:controller => 'spells', :action => 'index')
  end


end