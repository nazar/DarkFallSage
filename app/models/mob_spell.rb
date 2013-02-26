class MobSpell < ActiveRecord::Base

  belongs_to :mob
  belongs_to :spell

  named_scope :casts, {:conditions => 'mob_spell_type = 1'}
  named_scope :sells, {:conditions => 'mob_spell_type = 2'} 

  acts_as_revisable do
    except :updated_at, :created_at
  end

  after_save :update_mob_spells_count
  after_destroy :update_mob_spells_count

  #class methods

  def self.mob_spell_types
    {1 => 'uses', 2 => 'sells'}
  end

  def self.add_or_update_mob_spell(mob, key_id)
    raise "must be given a block" unless block_given?
    mob_spell = mob.mob_spells.find_by_id(key_id)
    mob_spell = mob.mob_spells.build if mob_spell.nil?
    yield mob_spell
  end

  #instance methods

  def revert_or_relink_first_revision(mob)
    if revisable_number > 1
      revert_to!(mob.reverting_to.mob_spells.find_by_spell_id(self.spell_id).revisable_number)
      self.mob = mob
      self.save(:without_revision => true)
    else #link to previous mob revision
      self.mob_id = mob.revisions.first.id
      self.save(:without_revision => true)
    end
  end

  private

  def update_mob_spells_count
    self.mob.spells_count = self.mob.mob_spells.count
    self.mob.save        
  end


end
