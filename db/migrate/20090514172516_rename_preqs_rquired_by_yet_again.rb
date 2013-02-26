class RenamePreqsRquiredByYetAgain < ActiveRecord::Migration

  def self.up
    rename_column :prereqs, :required_by_id,   :need_id
    rename_column :prereqs, :required_by_type, :need_type
    #
    add_index :prereqs, :need_id
  end

  def self.down
    rename_column :prereqs, :need_id, :required_by_id
    rename_column :prereqs, :need_type, :required_by_type 
  end
end
