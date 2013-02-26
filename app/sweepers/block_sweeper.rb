class  BlockSweeper < ActionController::Caching::Sweeper

  observe Item, Skill, Spell, Mob, Poi, Marker, Topic, Article, News

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
    #expire all blocks that register this record's class
    blocks = Block.registerd_by_class(record.class)
    Block.transaction do
      blocks.each do |block|
        Block.clear_cache_for(block)
      end
    end
  end


end