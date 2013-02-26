module Admin::ArticlesHelper

  def body_form_column(record, input_name)
    fckeditor_textarea( :record, :body, :toolbarSet => 'Simple', :name => input_name, :width => '800px', :height => '400px' )
  end

  def categories_form_column(record, input_name)
    content_tag(:select, indented_categories_select(CategoryArticle.all, record.categories.collect{|cat|cat.id}),
            :multiple => true, :name => input_name<<'[]', :id => input_name)
  end


end