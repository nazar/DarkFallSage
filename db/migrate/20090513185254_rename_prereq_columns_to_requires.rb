class RenamePrereqColumnsToRequires < ActiveRecord::Migration
  def self.up
    rename_column :prereqs, :prereq_id, :required_by_id
    rename_column :prereqs, :prereq_type, :required_by_type
  end

  def self.down
    rename_column :prereqs, :required_by_id, :prereq_id
    rename_column :prereqs, :required_by_type, :prereq_type 
  end
end
