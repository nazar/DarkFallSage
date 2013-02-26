class SpellReagent < ActiveRecord::Base

  belongs_to :item
  belongs_to :spell

  #returns item reagents only from the items table
  def self.spell_items
    Item.reagents
  end
  
  def self.spell_items_for_select
    SpellReagent.spell_items.collect{|i| [i.name, i.id]}
  end

  def self.add_or_update_reagent(spell, id, item_id, qty, user)
    if qty.to_f > 0
      sr = spell.spell_reagents.find_by_id(id)
      sr = spell.spell_reagents.build if sr.nil?
      #update
      sr.item_id   = item_id
      sr.qty       = qty
      sr.added_by  = user.id
      sr.save!
    elsif id.to_i > 0
      SpellReagent.destroy(id)
    end
  end

end
