module ItemHelper

  def item_table_row(record, column, name = '', data_override = nil)
    unless record.send(column).blank?
      markaby do
        tr :class => cycle('odd', 'even') do
          td.item_header name.blank? ? column.humanize : name
          td.item_data   data_override.nil? ? record.send(column) : data_override
        end
      end
    end  
  end

  def item_table_row_table(record, column, name = '', data_override = nil)
    content_tag(:table, item_table_row(record, column, name, data_override), :cellpadding => '0', :cellspacing => '0')
  end

  def item_categories_nav(active=nil)
    #sort item categories by name
    types = ''
    Item.item_types.sort{|a,b| a[1]<=>b[1]}.each do |item_type|
      subs = ''
      unless Item.item_sub_types(item_type.first).blank?
        Item.item_sub_types(item_type.first).sort{|a,b|a[1]<=>b[1]}.each do |sub_item|
          subs << content_tag(:li, link_to(sub_item.last.humanize, items_type_sub_path(item_type.first, sub_item.first)), :id => "item_#{item_type.first}_sub_#{sub_item.first}")
        end
        subs = content_tag(:ul, subs)
      end
      css_class = item_type.first.to_i == active.to_i ? 'open' : 'closed'
      types << content_tag(:li, link_to(item_type.last.humanize,items_by_type_path(item_type.first)) << subs, :id => "item_#{item_type.first}", :class => css_class)
    end
    content_tag(:div, content_tag(:ul, types, :class => 'jstree-default'), :id => 'item_types', :class=>"tree")
  end

  def item_type_and_sub_crumb(item)
    link = link_to item.item_type_to_s, items_by_type_path(item.item_type)
    if (item.item_sub_type.to_i > 0) && (item.item_subtype_to_s != '')
      link << ' - ' << link_to(item.item_subtype_to_s, items_type_sub_path(item.item_type, item.item_sub_type))
    end
    link
  end

end
