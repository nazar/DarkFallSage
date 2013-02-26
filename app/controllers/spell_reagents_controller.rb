class SpellReagentsController < ApplicationController

  before_filter :login_required,  :redirect_to => :login_path

  def reagent
    spell_reagent = SpellReagent.new(:qty => 1)
    spell_reagent.id = rand(10000) * -1   #temp number to hook css selectors
    respond_to do |format|
      format.js {render :partial => 'spell_reagents/spell_reagent_row', :locals => {:spell_reagent => spell_reagent} }
    end
  end

end
