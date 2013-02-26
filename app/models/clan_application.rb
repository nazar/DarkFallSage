class ClanApplication < ActiveRecord::Base

  belongs_to :clan
  belongs_to :user
  belongs_to :actioner, :foreign_key => 'actioned_by', :class_name => 'User'

  named_scope :not_rejected, {:conditions => 'status <> 3'}
  named_scope :pending, {:conditions => 'status <> 2'}

  #class methods

  def self.statuses
    {0 => 'Unkonwn', 1 => 'Pending Approval', 2 => 'Approved', 3 => 'Rejected'}
  end

  #instance methods

  def status_to_s
    ClanApplication.statuses[status]
  end

end
