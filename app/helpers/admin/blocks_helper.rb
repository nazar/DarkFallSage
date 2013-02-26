module Admin::BlocksHelper

  def content_form_column(record, input_name)
    fckeditor_textarea( :record, :content, :toolbarSet => 'Simple', :name => input_name, :width => '800px', :height => '400px' )
  end

  def block_type_form_column(record, input_name)
    select_tag input_name, options_for_select(Block.block_types_for_select, record.block_type) 
  end

  def placement_form_column(record, input_name)
    select_tag input_name, options_for_select(Block.placements_for_select, record.placement)
  end

  def placement_option_form_column(record, input_name)
    select_tag input_name, options_for_select(Block.placement_options_for_select, record.placement_option)
  end

  def dynamic_block_form_column(record, input_name)
    select_tag input_name, options_for_select(Block.dynamic_blocks_for_select, record.dynamic_block)
  end

end
