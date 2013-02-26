class MarkupController < ApplicationController

  before_filter :login_required, :redirect_to => :login_path

  skip_before_filter :verify_authenticity_token
  
  def preview_content
    return unless request.post?
    if params.index(:content).nil?
      content = content_from_method_name
    else
      content = content_from_target
    end
    unless content.blank?
      rc = RedCloth.new(content)
      content = rc.to_html
    end
    render :text => content
  end

  protected

  def content_from_method_name
    unless params[:control].blank? || params[:object].blank?
      control = params[:control].to_sym
      object  = params[:object].to_sym
      params[object].blank? || params[object][control].blank? ? '' : params[object][control]
    end
  end

  def content_from_target
    unless params[:content].blank? 
      control = params[:content].to_sym
      params[control].blank? ? '' : params[control]
    end
  end

end