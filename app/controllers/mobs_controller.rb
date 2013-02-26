class MobsController < ApplicationController

  helper :markup, :mobs

  before_filter :login_required, :only => [:new, :create, :edit, :edit_submit, :update, :destroy, :properties, :drops, :skins, :casts, :sells_items, :sells_spells],
                :redirect_to => :login_path

  after_filter :clear_slug_cache, :only => [:show]

  def index
    @mobs = Mob.paginate :order => 'name ASC', :page => params[:page], :per_page => 40, :include => :slugs #TODO add setup class & make configurable
    @page_title = 'Darkfall Mobs - Darkfall Sage'
  end

  def show
    @mob = Mob.find(params[:id])
    @topics  = @mob.topics.all_includes.paginate :page => params[:page_topics], :per_page => 25 #TODO add to config
    @images  = @mob.images.paginate :page => params[:page_images], :per_page => 20 #TODO add to config
    @last_approved = Mob.last_approved(@mob)
    if @mob.mob_type == 1
      @drops      = SlugCache.register_cache(Item) {@mob.items_drop}
      @skins      = SlugCache.register_cache(Item) {@mob.items_skins}
      @casts      = SlugCache.register_cache(Spell) {@mob.spells_casts}
    else
      @item_sells  = SlugCache.register_cache(Item) {@mob.items_sells}
      @spell_sells = SlugCache.register_cache(Spell) {@mob.spells_sells}
    end  
    @page_title = "#{@mob.name.humanize} - Mobs Database - Darkfall Sage"
  end

  def new
    is_reputable_to do
      @mob = Mob.new(:mob_type => 1) #default to mob
      #mob
      @drops = @mob.mob_items.drops
      @skins = @mob.mob_items.skins
      @casts = @mob.mob_spells.casts
      #npc
      @sells_items  = @mob.mob_items.sells
      @sells_spells = @mob.mob_spells.sells
    end  
  end

  def create
    Mob.transaction do
      @mob = Mob.new(params[:mob])
      @mob.created_by = current_user.id
      if manage_mob_revisions(@mob)
        redirect_to mob_path(@mob)
      else
        new
        render :action => 'new'
      end
    end  
  end

  def edit
    mob_info_from_pid
    @edit_map = Moderator.db_moderator?(current_user)
  end

  #edit or delete.... delete only by moderators
  def edit_submit
    unless request.post?
      redirect_to mobs_path
      return
    end
    is_reputable_to do
      @edit_map = Moderator.db_moderator?(current_user)
      mob_info_from_pid
      if params[:delete]
        can_db_moderate do
          Mob.transaction do
            @mob.destroy
            redirect_to mobs_path
          end
        end
      elsif params[:edit]
        render :action => :edit
      else
        render :text => 'invalid', :status => 404
      end
    end  
  end  

  def update
    Mob.transaction do
      @mob = Mob.find params[:id]
      @mob.attributes = params[:mob]
      MobWeakness.add_weaknesses_to_mob(@mob, MobWeakness::WeaknessSpell, params[:weak_spell])
      MobWeakness.add_weaknesses_to_mob(@mob, MobWeakness::WeaknessMelee, params[:weak_melee])
      @mob.cache_spell_and_melee_weakness(params[:weak_spell], params[:weak_melee])
      @mob.updated_by = current_user.id
      if manage_mob_revisions(@mob)
        redirect_to mob_path(@mob)
      else
        edit
        render :action => 'edit'
      end
    end
  end

  def by_letter
    unless params[:letter].blank?
      unless params[:letter].length > 1
        @mobs = Mob.paginate :conditions => ['mobs.name like ?', "#{params[:letter]}%"],  :order => 'name ASC',
                             :page => params[:page], :per_page => 40, :include => :slugs #TODO add setup class & make configurable
        @page_title = 'Darkfall Mobs - Darkfall Sage - Filtered by ' << params[:letter]
        render :action => :index
      else
        redirect_to mobs_path
      end  
    else
      redirect_to mobs_path
    end
  end

  def markers
    mob = Mob.find(params[:id])
    render :text => markers_to_markup(mob.markers.good)
  end

  def my_markers
    mob = Mob.find(params[:id])
    render :text => markers_to_markup(mob.markers.by_user(current_user))
  end

  def properties
    @mob = Mob.new(params[:mob])
    #mob
    @drops = @mob.mob_items.drops
    @skins = @mob.mob_items.skins
    @casts = @mob.mob_spells.casts
    #npc
    @sells_items  = @mob.mob_items.sells
    @sells_spells = @mob.mob_spells.sells
    respond_to do |format|
      format.js do
        case params[:mob][:mob_type].to_i
          when 1; render :partial => 'mobs/form_mob'
          when 2; render :partial => 'mobs/form_npc'
        end
      end
    end
  end

  def drops
    drop    = MobItem.new(:mob_item_type => 1, :quantity => 1)
    drop.id = rand(10000)*-1 
    respond_to do |format|
      format.js {render :partial => 'mobs/edit_drop', :locals => {:drop => drop}}
    end
  end

  def skins
    skin    = MobItem.new(:mob_item_type => 2, :quantity => 1)
    skin.id = rand(10000)*-1
    respond_to do |format|
      format.js {render :partial => 'mobs/edit_skin', :locals => {:skin => skin}}
    end
  end

  def casts
    cast    = MobSpell.new(:mob_spell_type => 1, :quantity => 1)
    cast.id = rand(10000)*-1
    respond_to do |format|
      format.js {render :partial => 'mobs/edit_cast', :locals => {:cast => cast}}
    end
  end

  def sells_items
    item    = MobItem.new(:mob_item_type => 1, :quantity => 1)
    item.id = rand(10000)*-1
    respond_to do |format|
      format.js {render :partial => 'mobs/edit_sells_item', :locals => {:item => item}}
    end
  end

  def sells_spells
    spell    = MobSpell.new(:mob_spell_type => 1, :quantity => 1)
    spell.id = rand(10000)*-1
    respond_to do |format|
      format.js {render :partial => 'mobs/edit_sells_spell', :locals => {:spell => spell}}
    end
  end

  def revisions
    show
    @show_title = "#{@mob.name.humanize} - Latest Revision - #{@mob.revision_number}"
    @revisions = @mob.revisions.collect{|rev| [rev.revisable_number, rev.revisable_original_id]}
    #
    revision
  end

  def revision
    @revision   = params[:revision].blank? ? :previous : params[:revision].to_i
    @rev_mob    = Mob.find(params[:id]).find_revision @revision
    unless @rev_mob.blank?
      if @rev_mob.mob_type == 1
        @rev_drops = @rev_mob.items_drop
        @rev_skins = @rev_mob.items_skins
        @rev_casts = @rev_mob.spells_casts
      else
        @rev_item_sells  = @rev_mob.items_sells
        @rev_spell_sells = @rev_mob.spells_sells
      end
      @rev_title = "#{@rev_mob.name.humanize} - @ Revision #{@rev_mob.revision_number}"
    end
  end

  def approve
    can_db_moderate do
      mob = Mob.find params[:id]
      updater = mob.updater || mob.user
      Mob.transaction do
        rep_type = params[:approve] ? :good : params[:reject] ? :bad : :error
        if rep_type == :good
          mob.approved_by = current_user
          mob.approved_at = Time.now
          mob.save(:without_revision => true)
        elsif rep_type == :bad #revert to previous version
          unless mob.find_revision(:previous).blank?
            mob = mob.revert_to! :previous #mob calls backs handle the association reverts
            #
            mob.approved_by = current_user
            mob.approved_at = Time.now
            mob.save(:without_revision => true)
          else #delete record plus associated mob_items and mob_spells
            Reputation.record_reputation_by_class(:mob, mob.name, updater, current_user, rep_type) #keep as we exit after destroy
            mob.destroy
            redirect_to mobs_path
            return #exit here
          end
        end
        #increase updater's reputation
        Reputation.record_reputation_by_class(:mob, mob.name, updater, current_user, rep_type)
      end
      #
      redirect_to mob_path(mob)
    end
  end

  def revert
    can_db_moderate do
      Mob.transaction do
        mob = Mob.find params[:id]
        mob = mob.revert_to! params[:revert].to_i #mob calls backs handle the association reverts
        mob.approved_by = current_user
        mob.approved_at = Time.now
        mob.save(:without_revision => true)
        #
        redirect_to mob_path(mob)
      end  
    end
  end

  def unapproved
    can_db_moderate do
      @mobs = Mob.latest.unapproved.paginate :page => params[:page], :per_page => 40, :include => :slugs
      @page_title = 'Unapproved Darkfall Mobs - Darkfall Sage'
    end  
  end

  protected

  def save_relationships(mob)
    save_item_drops(mob)
    save_item_skins(mob)
    save_item_sells(mob)
    save_spell_casts(mob)
    save_spell_sells(mob)
  end

  #save passed mob object but revise only if required
  def manage_mob_revisions(mob)
    unless Reputation.revise?(current_user)  
      mob.approved_by = current_user
      mob.approved_at = Time.now
      mob.save(:without_revision => true)
      save_relationships(mob)
      #reputation to moderators
      Reputation.record_reputation_by_class(:mob, mob.name,  mob.updater || mob.user, current_user, :good)
      #
      result = true
    else #untrusted creation/revision... save, notify admin and uprev
      last = mob.revision_number.to_i
      #
      result = mob.valid?
      if result
        mob.revise! #approval cleared in mob callback
        mob.changeset do
          save_relationships(mob)
        end
        if Reputation.revise_and_notify?(current_user)
          current = mob.revision_number
          link = "http://darkfallsage.com/mobs/#{mob.id}"
          if (current > 1) #update
            diff = mob.diffs(mob.revisions.first)
            UserMailer.deliver_notify_admin_obj_edited(User.admins, mob, link, diff, current_user)
          else #create
            UserMailer.deliver_notify_admin_obj_added(User.admins, mob, link, current_user)
          end
        end
      end
    end
    result
  end

  def sorted_param_hash(collection)
    collection.sort{|a,b| b[0]<=>a[0]}
  end

  def save_item_drops(mob)
    unless params[:drop].blank?
      sorted_param_hash(params[:drop]).each do |entry|
        MobItem.add_or_update_mob_item(mob, entry.first) do |mob_item|
          mob_item_from_params(mob_item, entry.last, 1)
        end
      end
    end
  end

  def save_item_skins(mob)
    unless params[:skin].blank?
      sorted_param_hash(params[:skin]).each do |entry|
        MobItem.add_or_update_mob_item(mob, entry.first) do |mob_item|
          mob_item_from_params(mob_item, entry.last, 2)
        end
      end
    end
  end

  def save_item_sells(mob)
    unless params[:item_sell].blank?
      sorted_param_hash(params[:item_sell]).each do |entry|
        MobItem.add_or_update_mob_item(mob, entry.first) do |mob_item|
          mob_item_from_params(mob_item, entry.last, 3)
        end
      end
    end
  end

  def save_spell_casts(mob)
    unless params[:cast].blank?
      sorted_param_hash(params[:cast]).each do |entry|
        MobSpell.add_or_update_mob_spell(mob, entry.first) do |mob_spell|
          mob_spell_from_params(mob_spell, entry.last, 1)
        end
      end
    end
  end

  def save_spell_sells(mob)
    unless params[:spell_sell].blank?
      sorted_param_hash(params[:spell_sell]).each do |entry|
        MobSpell.add_or_update_mob_spell(mob, entry.first) do |mob_spell|
          mob_spell_from_params(mob_spell, entry.last, 2)
        end
      end
    end
  end

  def mob_item_from_params(mob_item, param, mob_type)
    if  param[:quantity].to_f > 0
      #same item keyed in twice?
      if mob_item.new_record?
        prev = MobItem.find_by_mob_id_and_item_id(mob_item.mob_id, param[:item_id].to_i)
        mob_item = prev unless prev.blank?
        mob_item.quantity      = mob_item.quantity.to_f > 0 ? mob_item.quantity + param[:quantity].to_f : param[:quantity].to_f #add prev quantity
      else
        mob_item.quantity      = param[:quantity].to_f
      end
      mob_item.item_id       = param[:item_id].to_i
      mob_item.mob_item_type = mob_type
      mob_item.frequency     = param[:frequency].to_i
      mob_item.save(:without_revision => true)
    else
      MobItem.destroy(mob_item.id) unless mob_item.id.blank?
    end
  end

  def mob_spell_from_params(mob_spell, param, spell_type)
    if param[:quantity].to_f > 0
      #same spell keyed in twice?
      if mob_spell.new_record?
        prev = MobSpell.find_by_mob_id_and_spell_id(mob_spell.mob_id, param[:spell_id].to_i)
        mob_spell = prev unless prev.blank?
        mob_spell.quantity      = mob_spell.quantity.to_f > 0 ? mob_spell.quantity + param[:quantity].to_f : param[:quantity].to_f #add prev quantity
      else
        mob_spell.quantity      = param[:quantity].to_f
      end
      mob_spell.spell_id       = param[:spell_id].to_i
      mob_spell.mob_spell_type = spell_type
      mob_spell.save(:without_revision => true)
    else
      MobSpell.destroy(mob_spell.id) if mob_spell.id > 0
    end
  end

  def mob_info_from_pid
    @mob = Mob.find params[:id]
    @weak_spell = @mob.mob_weaknesses.spell_weakness
    @weak_melee = @mob.mob_weaknesses.melee_weakness
    @markers = @mob.markers
    @drops = @mob.mob_items.drops
    @skins = @mob.mob_items.skins
    @casts = @mob.mob_spells.casts
    @sells_items = @mob.mob_items.sells
    @sells_spells = @mob.mob_spells.sells
  end

end
