class PoiRevision < ActiveRecord::Base

  belongs_to :user,     :foreign_key => 'added_by'
  belongs_to :updater,  :foreign_key => 'updated_by', :class_name => 'User'
  belongs_to :approver, :foreign_key => 'approved_by', :class_name => 'User'

  acts_as_revision

  #instance methods

  def poi_type_to_s
    Poi.poi_types[poi_type]
  end
  

end