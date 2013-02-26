class  ItemSweeper < ActionController::Caching::Sweeper

  observe Item

  def after_create(item)
    expire_cache_for(item)
  end

  def after_update(item)
    expire_cache_for(item)
  end

  def after_destroy(item)
    expire_cache_for(item)
  end

  private

  def expire_cache_for(record)
    expire_action(:controller => 'items', :action => 'index')
  end


end