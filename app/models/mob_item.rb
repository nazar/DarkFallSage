class MobItem < ActiveRecord::Base

  belongs_to :item
  belongs_to :mob

  named_scope :drops, {:conditions => 'mob_item_type = 1'}
  named_scope :skins, {:conditions => 'mob_item_type = 2'} 
  named_scope :sells, {:conditions => 'mob_item_type = 3'}

  acts_as_revisable do
    except :updated_at, :created_at
  end

  #class methods

  def self.mob_item_types
    {1 => 'drop', 2 => 'harvest', 3 => 'sell'}
  end

  def self.frequency_types
    {1 => 'always', 2 => 'usually', 3 => 'often', 4 => 'sometimes', 5 => 'scarcely', 6 => 'rare'}
  end

  def self.add_or_update_mob_item(mob, key_id)
    raise "must be given a block" unless block_given?
    mob_item = mob.mob_items.find_by_id(key_id)
    mob_item = mob.mob_items.build if mob_item.nil?
    yield mob_item
  end

  #instance methods

  def revert_or_relink_first_revision(mob)
    if revisable_number > 1
      revert_to!(mob.reverting_to.mob_items.find_by_item_id(self.item_id).revisable_number) 
      self.mob = mob
      self.save(:without_revision => true)
    else #link to previous mob revision
      self.mob_id = mob.revisions.first.id
      self.save(:without_revision => true)
    end
  end

  def frequency_to_s
    MobItem.frequency_types[frequency].capitalize
  end

end
