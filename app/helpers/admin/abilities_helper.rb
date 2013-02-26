module Admin::AbilitiesHelper

  def description_form_column(record, input_name)
    fckeditor_textarea( :record, :description, :toolbarSet => 'Simple', :name => input_name, :width => '800px', :height => '400px' )
  end

end
