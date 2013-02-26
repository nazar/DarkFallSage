module Admin::NewsHelper

  def news_body_form_column(record, input_name)
    fckeditor_textarea( :record, :news_body, :toolbarSet => 'Simple', :name => input_name, :width => '800px', :height => '400px' )
  end

  def news_categories_override_form_column(record, input_name)
    content_tag(:select, indented_categories_select(CategoryNews.all, record.categories.collect{|cat|cat.id}),
            :multiple => true, :name => input_name<<'[]', :id => input_name)
  end
  
end
