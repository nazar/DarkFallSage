class SpellsController < ApplicationController

  helper :markup, :item

  before_filter :login_required, :only => [:new, :create, :edit, :update, :destroy],
          :redirect_to => :login_path


  caches_action :index

  cache_sweeper :spell_sweeper, :only => [:create, :update, :destroy]

  def index
    @schools = Skill.schools.all :include => {:spells => :slugs}
    @page_title = 'Spells Database - Darkfall Sage'
  end

  def show
    @spell    = Spell.find params[:id], :include => :reagents
    @reagents = Item.reagents_for_spell(@spell).paginate :order => 'items.name', :page => params[:page_reagents], :per_page => 25 #TODO add to config
    @sellers  = @spell.sellers
    @images   = @spell.images.paginate :page => params[:page_images], :per_page => 20 #TODO add to config
    @topics   = @spell.topics.paginate :include => [:user, :replied_by_user, :last_post], :page => params[:page_topics], :per_page => 25 #TODO add to config
    #
    @page_title = "#{@spell.name} - Darkfall Sage Spell Database"
    @page_description = @spell.description.to_redcloth unless @spell.description.blank?
    #
    respond_to do |format|
      format.html {}
      format.js do
        if params.keys.include?('page_images')
          render :partial => 'images/images_tab', :locals => {:images => @images, :objekt => @spell}
        else
          render :partial => 'spells/ajax_spell_popup'
        end
      end
    end
  end

  def new
    can_db_moderate do
      #create new blank spell and set spell type and spell_target to first alpha sorted spell type
      @spell = Spell.new(
              :level => 1,
              :spell_type => Spell.spell_types_sorted_for_select_first,
              :spell_target => Spell.spell_targets_sorted_for_select_first )
    end
  end

  def create
    can_db_moderate do
      Spell.transaction do
        @spell = Spell.new(params[:spell])
        @spell.added_by = current_user.id
        @spell.save
        if @spell.errors.blank?
          #check if there are any prereq
          save_prereqs(@spell)
          save_reagents(@spell)
          #done
          redirect_to spells_path
        else
          render :action => 'new'
        end
      end  
    end  
  end

  def update
    can_db_moderate do
      Spell.transaction do
        @spell = Spell.find params[:id]
        @spell.attributes = params[:spell]
        @spell.updated_by = current_user.id
        @spell.save
        if @spell.errors.blank?
          #check if there are any prereq
          save_prereqs(@spell)
          save_reagents(@spell)
          #done
          redirect_to spell_path(@spell)
        else
          render :action => 'edit'
        end
      end
    end  
  end

  def edit
    can_db_moderate do
      @spell = Spell.find params[:id]
    end  
  end

  def destroy
  end

  def by_effect
    @effect = params[:id].to_i
    @spells = Spell.spells_by_effect(@effect).all :include => [{:school => :slugs}, :slugs]
    @spell_effect = Spell.spell_types[@effect].capitalize
    @page_title = "Spells by Effect #{@spell_effect} - Darkfall Sage Spells Database"
  end

  def by_school
    @school = Skill.find params[:id]
    @spells = @school.spells.all :include => :slugs, :order => 'spells.level ASC'
    @school_type = @school.name
    @page_title = "Spells in School #{@school_type} - Darkfall Sage Spells Database"
  end

  protected

  def save_reagents(spell)
    unless params[:spell_reagent].blank?
      params[:spell_reagent].each do |key, value|
        SpellReagent.add_or_update_reagent(spell, key, value[:item_id], value[:qty], current_user)
      end
    end
  end

end
