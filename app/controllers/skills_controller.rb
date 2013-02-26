class SkillsController < ApplicationController

  helper :markup, :item

  before_filter :login_required, :only => [:new, :create, :edit, :update, :destroy],
          :redirect_to => :login_path

  skip_before_filter :verify_authenticity_token, :only => [:properties]

  caches_action :index

  cache_sweeper :skill_sweeper, :only => [:create, :update, :destroy]

  def index
    @hash_orders, @skills_hash = Skill.all_as_type_hash
    @page_title = 'Skills Database - Darkfall Sage'
  end

  def show
    @skill       = Skill.find params[:id]
    @spells      = @skill.spells.all :order => 'level ASC', :include => :slugs
    @required_by = Item.items_for_skill(@skill).all :include => :slugs
    @images      = @skill.images.paginate :page => params[:page_images], :per_page => 20 #TODO add to config
    @topics      = @skill.topics.paginate :include => [:user, :replied_by_user, :last_post], :page => params[:page_topics], :per_page => 25 #TODO add to config
    #
    @page_title = "#{@skill.name} - Darkfall Sage Skill Database"
    @page_description = @skill.description.to_redcloth unless @skill.description.blank?
    #
    respond_to do |format|
      format.html {}
      format.js do
        if params.keys.include?('page_images')
          render :partial => 'images/images_tab', :locals => {:images => @images, :objekt => @skill}
        end
      end
    end

  end

  def edit
    can_db_moderate do
      @skill = Skill.find params[:id]
    end
  end

  def update
    can_db_moderate do
      Skill.transaction do
        @skill = Skill.find params[:id]
        @skill.attributes = params[:skill]
        @skill.updated_by = current_user.id
        @skill.save
        if @skill.errors.blank?
          #check if there are any prereq
          save_prereqs(@skill)
          #done
          redirect_to skill_path(@skill)
        else
          render :action => 'edit'
        end
      end
    end  
  end

  def create
    can_db_moderate do
      @skill = Skill.new(params[:skill])
      @skill.added_by = current_user.id
      @skill.save
      if @skill.errors.blank?
        #check if there are any prereq
        save_prereqs(@skill)
        #done
        redirect_to skills_path
      else
        render :action => 'new'
      end
    end  
  end

  def new
    can_db_moderate do
      #create new blank skill and set skill type to first alpha sorted skill type
      @skill = Skill.new(:skill_type => Skill.skill_types.sort{|a,b| a[1] <=> b[1]}.first.first)
    end  
  end

  def destroy
  end

  def by_type
    @skills = Skill.skills_by_type(params[:id]).all :include => :slugs
    @skill_type = Skill.skill_types[params[:id].to_i].capitalize
    @page_title = "Skills of type #{@skill_type} - Darkfall Sage Skill Database"
  end

  def properties
    skill = Skill.new(:skill_type => params[:skill][:skill_type])
    unless Skill.skill_sub_types[skill.skill_type].blank?
      respond_to do |format|
        format.js  {render :partial => 'skill_properties_by_type', :locals => {:type => skill.skill_type}}
      end
    else
      respond_to do |format|
        format.js  {render :text => 'No skill sub type'}
      end
    end
  end


end
