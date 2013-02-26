class Block < ActiveRecord::Base


  named_scope :center_blocks, :conditions => 'placement = 1', :order => 'position ASC'
  named_scope :left_blocks, :conditions => 'placement = 0', :order => 'position ASC'
  named_scope :darkfall_server_status, :conditions => {:dynamic_block => 3, :block_type => 1}
  named_scope :registerd_by_class, lambda{|klass|
    {:conditions => ['block_class like ?', "%#{klass.name}%"]}
  }

  def self.block_types
    {0 => 'static', 1 => 'dynamic'}
  end

  def self.placements
    { 0 => 'left column', 1=> 'center column',  2 => 'right column'}
  end

  def self.placement_options
    { 0 => 'full', 1 => 'half', 2 => 'third' }
  end

  #id is linked to #blocks_helper methods
  def self.dynamic_blocks
    { 0 => 'item_type_menu', 1 => 'spell_efect_type_menu', 2 => 'skill_type_menu', 3 => 'darkfall_server_status',
      4 => 'spell_schools', 5 => 'item_latest_created', 6 => 'item_latest_updated', 7 => 'spell_latest_updated',
      8 => 'spell_latest_created', 9 => 'site_metrics', 10 => 'latest_news', 11 => 'latest_articles',
      12 => 'latest_topics', 14 => 'latest_images', 15 => 'top_reputations', 16 => 'latest_mobs', 17 => 'latest_markers' }
  end

  def self.block_types_for_select
    Block.block_types.sort.collect{|t| [t.last, t.first]}
  end

  def self.placements_for_select
    Block.placements.sort.collect{|p| [p.last, p.first]}
  end

  def self.placement_options_for_select
    Block.placement_options.sort.collect{|p| [p.last, p.first]}
  end

  def self.dynamic_blocks_for_select
    Block.dynamic_blocks.sort{|a,b| a[1]<=>b[1]}.collect{|p| [p.last, p.first]}
  end

  def self.clear_cache_for(block)
    block.cached_content = ''
    block.save
  end

  #instance methods

  def block_type_to_s
    Block.block_types[block_type]
  end

  def dynamic_block_to_s
    Block.dynamic_blocks[dynamic_block]
  end

  def placement_to_s
    Block.placements[placement]
  end

  def placement_option_to_s
    Block.placement_options[placement_option]
  end


end
