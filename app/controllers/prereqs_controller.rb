class PrereqsController < ApplicationController

  before_filter :login_required, :redirect_to => :login_path

  skip_before_filter :verify_authenticity_token, :only => [:type_objects, :prereq]

  #returns abilities when given a prereq type
  def type_objects
    pre = Prereq.new(:need_type => params[:type])
    pre.id = params[:id].to_i
    respond_to do |format|
      format.js {render :partial => 'prereqs/prereq_items_by_type', :locals => {:prereq => pre}}
    end
  end

  #always called for new line
  def prereq
    prereq = Prereq.new(:need_type => Prereq.first_prereq_type)
    prereq.id = rand(10000) * -1   #temp number to hook css selectors
    respond_to do |format|
      format.js {render :partial => 'prereqs/edit_prereq', :locals => {:prereq => prereq} }
    end
  end

  

end
