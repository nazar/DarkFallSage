class HomeController < ApplicationController

  helper :news, :articles

  def index
    @page_title    = 'Darkfall Sage - The Complete Darkfall Resource'
    @center_blocks = Block.center_blocks
  end

end
