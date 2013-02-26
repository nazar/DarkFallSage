class AllianceLog < ActiveRecord::Base

  belongs_to :alliance
  belongs_to :clan #TODO not so sure of this link

  #class methods

  def self.log_event(log, alliance, clan = nil)
    alliance.alliance_logs.create(:clan => clan, :log => log)
  end

end
