class Category < ActiveRecord::Base

  #class methods

  #if category has parents, then walk up the tree and increment all counts
  def self.increment_to_top(category)
    category.item_counts += 1
    category.save
    self.increment_to_top(category.parent) unless category.parent.nil?
  end

  #if category has parents, then walk up the tree and decrement all counts
  def self.decrement_to_top(category)
    if category.item_counts > 0
      category.item_counts -= 1
      category.save
      self.decrement_to_top(category.parent) unless category.parent.nil?
    end
  end

  #istance mehtods

  def get_items
    ##abstract to be filled by super
  end

  def label
    self.category
  end

  #get currently attached items plus all items against children
  def all_items_in_tree
    items = []
    get_items.each{|item| items << item unless item.blank?}
    if children.length > 0
      children.each do |child|
        child.all_items_in_tree.each{|item| items << item unless item.blank?}
      end
    end
    items
  end

end
