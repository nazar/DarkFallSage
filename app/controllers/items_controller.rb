class ItemsController < ApplicationController

#  verify :method => :post, :only => [ :create, :reply ]
  helper :markup, :item

  before_filter :login_required, :only => [:new, :create, :edit, :update, :destroy],
          :redirect_to => :login_path

  after_filter :clear_slug_cache, :only => [:show]

  skip_before_filter :verify_authenticity_token, :only => [:properties]

  caches_action :index

  cache_sweeper :item_sweeper, :only => [:create, :update, :destroy]

  def index
    #limit to first item type...expand first item
    @item_type_id = Item.item_types_for_select.first.last
    @item_type  = Item.item_types[@item_type_id].humanize
    @items = Item.all :conditions => ['item_type = ?', @item_type_id], :include => :slugs
    @page_title = "Items Database - Darkfall Sage"
  end

  def new
    can_db_moderate do
      @item = Item.new(:item_type => Item.item_types.sort{|a,b| a[1] <=> b[1]}.first.first)
      #set item_type to first alphabetically sorted item_type_id
    end  
  end

  def show
    @item = Item.find params[:id], :include => [:prereqs]
    @item_type_id = @item.item_type
    #needed by this item...i.e. if this is gold then it is needed by skill, items and spells
    @req_by_spell = SlugCache.register_cache(Spell) {Spell.required_by_item(@item)}
    @req_by_skill = SlugCache.register_cache(Skill) {Skill.required_by_item(@item)}
    @req_by_item  = SlugCache.register_cache(Item) {Item.required_by_item(@item)}

    @by_spells    = SlugCache.register_cache(Spell) {Spell.spells_using_reagent(@item).paginate :page => params[:page_spells], :include => :school, 
                                                                                                :per_page => 25, :order => 'spells.name'} #TODO add to config
    @sold_by      = SlugCache.register_cache(Mob) {@item.sellers}
    @dropped_by   = SlugCache.register_cache(Mob) {@item.droppers}
    @topics       = @item.topics.paginate :include => [:user, :replied_by_user, :last_post], :page => params[:page_topics], :per_page => 25 #TODO add to config
    @images       = @item.images.paginate :page => params[:page_images], :per_page => 20 #TODO add to config
    @page_title   = "#{@item.name} - Darkfall Sage Item Database"
    @page_description = @item.description.to_redcloth unless @item.description.blank?
    respond_to do |format|
      format.html {}
      format.js do
        #this can either be for a popup or to paginate a tab
        unless (['page_spells', 'page_topics', 'page_images'] & params.keys).blank?
          if params.keys.include?('page_spells')
            render :partial => 'items/spells_tab'
          elsif params.keys.include?('page_images')
            render :partial => 'images/images_tab', :locals => {:images => @images, :objekt => @item}
          end
        else
          render :partial => 'items/popup_info'
        end
      end
    end
  end

  def edit
    can_db_moderate do
      @item = Item.find params[:id]
      @markers = @item.markers
    end  
  end

  def create
    can_db_moderate do
      @item = Item.new(params[:item])
      @item.added_by = current_user.id
      @item.save
      if @item.errors.blank?
        #check if there are any prereq
        save_prereqs(@item)
        #done.. continue
        redirect_to items_path
      else
        render :action => 'new'
      end
    end  
  end

  def update
    can_db_moderate do
      Item.transaction do
        @item = Item.find params[:id]
        @item.attributes = params[:item]
        @item.updated_by = current_user.id
        @item.save
        if @item.errors.blank?
          #check if there are any prereq
          save_prereqs(@item)
          #done.. continue
          redirect_to item_path(@item)
        else
          render :action => 'edit'
        end
      end
    end  
  end

  def destroy
  end

  def properties
    #common att only
    @item = Item.new(:name => params[:item][:name], :description => params[:item][:description],
            :weight => params[:item][:weight], :durability => params[:item][:durability], :npc_cost => params[:item][:npc_cost],
            :item_type => params[:item][:item_type])
    respond_to do |format|
      format.js {render :partial => 'item_properties_by_type', :locals => {:type => @item.item_type}}
    end
  end

  def by_type
    @items = Item.by_item_type(params[:id]).all :include => :slugs
    @item_type_id = params[:id].to_i
    @item_type  = Item.item_types[@item_type_id].capitalize
    @is_weapon = @item_type_id == Item::ItemWeapon
    @page_title = "Items Type #{@item_type} - Items Database - Darkfall Sage"
    @show_quality = @item_type_id == 10 ? ['show_quality'] : [] #show quality on enchanting items and subs
  end

  def by_sub_type
    @items = Item.by_item_type_and_sub(params[:id], params[:sub]).all :include => :slugs
    @item_type_id = params[:id].to_i
    @item_type  = Item.item_types[@item_type_id].capitalize
    @is_weapon = @item_type_id == Item::ItemWeapon
    @sub_item   = Item.item_sub_types[params[:id].to_i][params[:sub].to_i].blank? ? '' : Item.item_sub_types[params[:id].to_i][params[:sub].to_i].humanize 
    @page_title = "Items Type #{@item_type} - Items Database - Darkfall Sage"
    @show_quality = @item_type_id == 10 ? ['show_quality'] : [] #show quality on enchanting items and subs
  end

  def markers
    item = Item.find_by_id(params[:id])
    render :text => markers_to_markup(item.markers.good), :status => 200 
  end

  def my_markers
    item = Item.find_by_id(params[:id])
    render :text => markers_to_markup(item.markers.by_user(current_user)), :status => 200
  end


end
