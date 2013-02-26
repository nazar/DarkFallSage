module BlocksHelper

  require 'open-uri'
  require 'hpricot'

  #generic helpers

  def block_placement_to_css_class(block)
    result = ''
    if [1,2,3].include?(block.placement)
      result = case block.placement_option
        when 0; 'full_block'
        when 1; 'half_block'
        when 2; 'third_block'
      end
    end
    result
  end

  def get_dynamic_block_content(block)
    content = self.send block.dynamic_block_to_s
    content = content.to_s if content.is_a? Markaby::Builder
    content
  end

  def get_and_save_dynamic_block_content(block)
    content = get_dynamic_block_content(block)
    block.cached_content = content
    if block.refresh_rate.blank?
      rate = 5.minutes
    else
      rate = eval(block.refresh_rate)
    end
    block.cache_until = Time.now + rate if block.block_class.blank? 
    block.save!
    content
  end

  def render_block_content(block)
    if block.block_type == 0
      block.content
    else
      if block.cached
        if block.block_class.blank? #class based blocks are emptied by sweepers
          if (not block.cache_until.blank?) && (Time.now < block.cache_until)
            RAILS_DEFAULT_LOGGER.debug "Block Cache HIT: #{block.title}"
            block.cached_content
          else
            RAILS_DEFAULT_LOGGER.debug "Block Cache Miss: #{block.title}"
            get_and_save_dynamic_block_content(block)
          end
        else
          if block.cached_content.blank?
            RAILS_DEFAULT_LOGGER.debug "Block Cache Miss: #{block.title}"
            get_and_save_dynamic_block_content(block)
          else  
            RAILS_DEFAULT_LOGGER.debug "Block Cache HIT: #{block.title}"
            block.cached_content
          end
        end
      else
        get_dynamic_block_content(block)
      end
    end  
  end

  #renders left menu blocks only
  def render_left_blocks
    result = ''
    Block.left_blocks.each do |block|
      result << render(:partial => 'blocks/render_block', :locals => {:block => block})
    end
    result
  end

  #dynamic blocks . each dynamic block is a method in BlocksHelper

  def get_df_server_status(server = 'http://www.eu1.darkfallonline.com/news/')
    begin
      content = Hpricot(open(server))
      content = (content/'table/tr[2]/td[4]').to_html
      #
      players    = (content =~ /players_online/).blank?   ? 'offline-player' : 'online-player'
      gms        = (content =~ /gms_online/).blank?       ? 'offline-gm'     : 'online-gm'
      master_gms = (content =~ /mastergms_online/).blank? ? 'offline-mgm'    : 'online-mgm'
      admins     = (content =~ /admins_online/).blank?    ? 'offline-admin'  : 'online-admin'
    rescue
      players    = 'server/' << 'offline-player' << '.png'
      gms        = 'server/' << 'offline-gm' << '.png'
      master_gms = 'server/' << 'offline-mgm' << '.png'
      admins     = 'server/' << 'offline-admin' << '.png'
    end
    players    = 'server/' << players << '.png'
    gms        = 'server/' << gms << '.png'
    master_gms = 'server/' << master_gms << '.png'
    admins     = 'server/' << admins << '.png'
    markaby do
      div.server_status do
        image_tag players
        image_tag gms
        image_tag master_gms
        image_tag admins
      end
    end
  end

  def darkfall_server_status
    '<div style="text-align:center;"><strong>EU1</strong></div>' +
    get_df_server_status.to_s +
    '<div style="text-align:center;"><strong>US1</strong></div>' +
    get_df_server_status('http://www.us1.darkfallonline.com/news/').to_s
  end

  def item_type_menu
    collection_to_ul_li_links(Item.item_types_for_select) do |item|
      items_by_type_path(item.last) 
    end
  end

  def spell_efect_type_menu
    collection_to_ul_li_links(Spell.spell_types_sorted_for_select) do |spell|
      spell_by_type_path(spell.last)
    end
  end

  def skill_type_menu
    collection_to_ul_li_links(Skill.skill_type_for_select) do |skill|
      skill_by_type_path(skill.last)
    end
  end

  def article_category_menu
    
  end

  def spell_schools
    collection_to_ul_li_links(Skill.magic_skill_school_skills) do |spell|
      spell_by_school_path(spell.last)
    end
  end

  def item_latest_created
    render :partial => 'items/items_table',
           :locals => {:items => Item.latest_items_created(5), :trunc => 30, :table_id => 'item_latest_created', :hide => []}
  end

  def item_latest_updated
    render :partial => 'items/items_table',
           :locals => {:items => Item.latest_items_updated(5), :trunc => 30,  :table_id => 'item_latest_updated', :hide => []}
  end

  def spell_latest_updated
    render :partial => 'spells/spells_table',
           :locals => {:spells => Spell.latest_spells_updated(5), :trunc => 30,  :table_id => 'spell_latest_updated'}
  end

  def spell_latest_created
    render :partial => 'spells/spells_table',
           :locals => {:spells => Spell.latest_spells_created(5), :trunc => 30,  :table_id => 'spell_latest_created'}
  end

  def latest_news
    result = ''
    News.all(:limit => 1, :order => 'created_at DESC', :include => :slugs).each do |item|
      result << render(:partial => 'news/item_brief', :locals => {:item => item}) 
    end
    result
  end

  def latest_articles
    render :partial => 'articles/articles_summary', :locals => {:articles => Article.all(:limit =>5, :order => 'created_at desc')}
  end

  def site_metrics
    markaby do
      table :cellspacing => 0, :cellpadding => 0, :id => 'db_stats' do
        tr do
          td :width => '10px' do
            link_to "Items", '/items'
          end
          td Item.count 
        end
        tr do
          td {link_to "Skills", '/skills'}
          td Skill.count
        end
        tr do
          td {link_to "Spells", '/spells'}
          td Spell.count
        end
        tr do
          td {link_to "Mobs", '/mobs'}
          td Mob.count
        end
        tr do
          td {link_to "POI", '/points_of_interest', :title => 'Points of Interest'}
          td Poi.count
        end
        tr do
          td {link_to "Markers", '/maps'}
          td Marker.count
        end
      end
    end
  end

  def latest_images
    render :partial => 'images/images_block', :locals => {:images => Image.all(:limit => 12, :order => 'created_at desc')}
  end

  def latest_topics
    render :partial => 'forums/topics_table',
           :locals => {:topics => Topic.and_public_clans.all(:limit => 6, :order => 'replied_at desc', :include => [:posts, :user, :replied_by_user, :last_post])} 
  end

  def top_reputations
    users = User.top_reputation.all :include => :counter
    render :partial => 'sessions/user_table',
           :locals => {:users => users}
  end

  def side_top_reputations
    users = User.top_reputation.all :include => :counter
    render :partial => 'sessions/user_mini_table',
           :locals => {:users => users}
  end

  def latest_mobs
    mobs = Mob.recent(5)
    render :partial => 'mobs/mobs_table', :locals => {:mobs => mobs}
  end

  def latest_markers
    
  end

  protected

  def collection_to_ul_li_links(collection, &block)
    links = []
    collection.each do |item|
      link = block.call(item)
      links << content_tag(:li, link_to(item.first.capitalize, link))
    end
    content_tag(:ul, links.join)
  end

end
