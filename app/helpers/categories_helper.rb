module CategoriesHelper

  def indented_categories_select(categories, selected = nil)
    ret = '';
    bold = ''
    tree_recursive(categories,nil) do |t, level|
      if level == 5
        bold = 'class="bold"'
      else
        bold = ''
      end
      if selected && selected.index(t.id)
        ret << "<option style='padding-left:#{level.to_s}px' value='#{t.id}' selected='selected' #{bold} >#{t.category}</option>"
      else
        ret << "<option style='padding-left:#{level.to_s}px' value='#{t.id}' #{bold}>#{t.category}</option>"
      end
    end
    return ret
  end

  def indented_categories_list(categories)
    if categories.children.length > 0
      ret = '<ul>';
      tree_recursive(categories.children, categories.id, -10) do |t, level|
        link = link_to "#{t.category} (#{t.item_counts})", category_articles_path(t, t.category.to_permalink)
        ret << content_tag(:li, link, :style => "padding-left:#{level.to_s}px")
      end
      ret << '</ul>'
      return ret
    end
  end

  def tree_recursive(tree, parent_id = nil, level = -5)
    ret = '';
    level += 10
    tree.each do |node|
      if node.parent_id == parent_id
        ret << (yield node, level)
        ret << tree_recursive(tree, node.id, level) { |n,l| yield n, l }
      end
    end
    ret << ""
  end

end