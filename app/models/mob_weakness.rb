class MobWeakness < ActiveRecord::Base

  belongs_to :mob

  WeaknessSpell = 0
  WeaknessMelee = 1

  MeleePiercing = 1
  MeleeSlashing = 2
  MeleeBlunt    = 3

  named_scope :spell_weakness, :conditions => {:weakness_type => MobWeakness::WeaknessSpell}
  named_scope :melee_weakness, :conditions => {:weakness_type => MobWeakness::WeaknessMelee}

  #class methods

  #returns a hash of magic speel school id against name
  def self.spell_weaknesses
    Spell.sub_types
  end

  #returns a hash of melee wekaness types hash
  def self.melee_types
    {MobWeakness::MeleePiercing => 'piercing', MobWeakness::MeleeSlashing => 'slashing', MobWeakness::MeleeBlunt => 'blunt'}
  end

  def self.add_weaknesses_to_mob(mob, weakness_type, weaknesses)
    weaknesses.each do |key, value|
      weak = MobWeakness.find_or_initialize_by_mob_id_and_weakness_id_and_weakness_type(mob.id, key, weakness_type)
      weak.save if weak.new_record?
    end unless weaknesses.blank?
  end

  def self.weaknesses_to_cache(weakness_type, weaknesses)
    cache = []
    weaknesses.each do |key, value|
      if weakness_type == MobWeakness::WeaknessSpell
        cache << MobWeakness.spell_weaknesses[key.to_i].downcase
      elsif weakness_type == MobWeakness::WeaknessMelee
        cache << MobWeakness.melee_types[key.to_i]
      end
    end unless weaknesses.blank?
    cache.sort.join(', ')
  end

end
