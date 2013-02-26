class Admin::BlocksController < Admin::AdminController

  active_scaffold :blocks do |config|
    config.label = "Blocks"
    #columns
    config.list.columns    = [:title, :block_type_to_s, :dynamic_block_to_s, :placement_to_s, :placement_option_to_s, :cached, :block_class, :position, :created_at, :updated_at]

    update_columns = [:title, :block_type, :content, :dynamic_block, :placement, :placement_option, :cached, :block_class, :position, :refresh_rate]
    config.create.columns  = config.update.columns = update_columns 
  end
  
end
