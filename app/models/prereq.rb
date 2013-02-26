class Prereq < ActiveRecord::Base

  belongs_to :prereqable, :polymorphic => true
  belongs_to :need, :polymorphic => true

  #call backs to increment counters on attached reqs
  after_create :increment_req_counters
  after_save :update_prereq_gold_cache
  after_destroy :decrement_req_counters

  #instance methods

  #map class name against displayed name on combo. first = calss name, last = display name
  def self.prereq_types
    {'Skill' => 'skill', 'Item' => 'item', 'Spell' => 'spell', 'Ability' => 'stat'}
  end

  def self.prereq_types_for_select
    self.prereq_types.sort{|a,b|a[1]<=>b[1]}.collect{|i| [i.last.capitalize, i.first]}
  end

  def self.first_prereq_type
    self.prereq_types_for_select.first.last
  end

  def self.preq_items_by_type(type)
    #item special case as we want to irder by type then name
    if type == 'Item'
      type.constantize.all(:order => 'name').collect{|obj| [obj.name.capitalize, obj.id] }
    elsif type ==  'Skill'
      type.constantize.all(:order => 'name').collect{|obj| [obj.name.capitalize, obj.id] }
    else
      type.constantize.all(:order => 'name').collect{|obj| [obj.name.capitalize, obj.id] }
    end
  end

  def self.add_or_update_prereq(prerequable, p_id, preq_type, preq_id, preq_qty)
    if preq_qty.to_f > 0
      prereq = prerequable.prereqs.find_by_id(p_id)
      prereq = prerequable.prereqs.build if prereq.nil?
      #update
      prereq.need_type = preq_type
      prereq.need_id   = preq_id
      prereq.qty       = preq_qty
      prereq.save!
    elsif p_id.to_i > 0
      Prereq.destroy(p_id)
    end  
  end

  #given a parent, return a hash of types with children arrays
  def self.get_needs_by_type_hash(parent)
    result = {}
    parent.needed_by.each do |dependant|
      result[dependant.prereqable_type] = [] if result[dependant.prereqable_type].blank?
      result[dependant.prereqable_type] << dependant
    end
    result
  end

  def self.get_prereable_by_type_hash(reqable)
    result = {}
    reqable.prereqs.each do |prereq|
      result[prereq.need_type] = [] if result[prereq.need_type].blank?
      result[prereq.need_type] << prereq
    end
    result
  end

  #instance methods
  def type_to_s
    Prereq.prereq_types[need_type]
  end

  def object_name
    need.name
  end

  def update_gold_cache(destroy = false)
    if ['Skill', 'Spell'].include?(prereqable_type)
      @gold ||= Item.find 'gold'
      if need_id.to_i == @gold.id.to_i
        if destroy
          prereqable.gold = 0
        else
          prereqable.gold = qty
        end
        prereqable.save
      end
    end
  end


  protected

  def increment_req_counters
    unless need.blank?
      need.required_count += 1
      need.save
    end
  end

  def decrement_req_counters
    unless need.blank?
      if need.required_count > 0
        need.required_count -= 1
        need.save
      end
      update_gold_cache(true)
    end
  end

  def update_prereq_gold_cache
    update_gold_cache
  end

end
