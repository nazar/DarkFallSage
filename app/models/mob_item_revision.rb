class MobItemRevision < ActiveRecord::Base

  acts_as_revision

  belongs_to :mob, :class_name => "MobRevision"
  belongs_to :item

  before_create :reassociate_with_mob, :if => :mob_in_revision?
#  before_create :relink_after_revert, :if => :mob_reverting?

  private

  def reassociate_with_mob
    prev = self.current_revision.mob.find_revision(:previous)
    self.mob = prev
  end

  def relink_after_revert
    prev = Mob.find(self.mob_id).find_revision(:previous)
    self.mob = prev
  end

  def mob_in_revision?
    !self.current_revision.mob.nil? && self.current_revision.mob.revisable_number > 0
  end

  def mob_reverting?
    MobItem.revisable_current_states[:reverting] && (MobItem.revisable_current_states[:reverting][self.revisable_original_id])
  end


end
