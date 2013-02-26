class PrereqTypeToString < ActiveRecord::Migration
  def self.up
    change_column :prereqs, :prereq_type, :string, :limit => 20
  end

  def self.down
    change_column :prereqs, :prereq_type, :integer
  end
end
