module MarkupHelper

  protected

  #always call markup_area or markup_editor_tag
  def markup_area(name, method, options = {}, html_options = {})
    options[:delayed_load] = options[:delayed_load] === false ? false : true #defaults to true
    #
    result = markup_editor_area(name, method, options, html_options)
    #
    toolbar = wikitoolbar_for("#{name}_#{method}")
    if html_options[:delayed_load]
      add_footer_sript(toolbar)
    else
      result << javascript_tag("function loadToolbar() {var toolbar = new jsToolBar($('#{name}_#{method}')); toolbar.draw();}; loadToolbar(); ")
    end
    result
  end

  protected

  #do not call directly!!!!
  def markup_editor_area(name, method, options ={}, html_options ={})
    pl_caption = options.delete(:caption)
    pl_caption ||= "Preview #{method}"

    preview_dom_id = "#{name}_#{method}_preview"
    preview_target = "#{name}_#{method}_preview_target"

    pl_options            = {}
    pl_options[:url]      = {:controller => '/markup', :action => "preview_content", :object => name, :control => method}
    pl_options[:with]     = "Form.serializeElements([$('#{name}_#{method}')])"
    pl_options[:complete] = "Element.show('#{name}_#{method}_preview'); "
    pl_options[:update]   = preview_target
    pl_options.merge!(options)

    editor_opts = {:class => 'markup-editor'}.merge(html_options)
    #links
    markup_link = link_to('Textile Markup reference', "#{ActionController::Base.asset_host}/textile_reference.html",
                    :popup => ['Textile markup reference',
                       'height=400,width=520,location=0,status=0,menubar=0,resizable=1,scrollbars=1'])
    preview_link = link_to_remote(pl_caption, pl_options)

    links   = content_tag('div', markup_link + ' | ' + preview_link, {:class => 'markup-area-link'})
    #preview cntainer
    preview_close_link = link_to_function('Close preview', " Effect.toggle( $('#{preview_dom_id}'),'blind')")
    preview_target     = content_tag('div', '&nbsp;', :id => "#{preview_dom_id}_target", :class => 'markup-preview')
    preview            = content_tag('div', preview_target << "<div id='preview_link'>#{preview_close_link}</div>", :id => "#{preview_dom_id}", :style => 'display: none;')
    #render all
    content_tag('div', text_area(name, method, editor_opts) << links << preview , :id => "#{name}_#{method}_editor")
  end

  def wikitoolbar_for(field_id)
    javascript_include_tag('jstoolbar/jstoolbar') +
      javascript_include_tag("jstoolbar/lang/jstoolbar-en") +
      javascript_tag("function loadToolbar() {var toolbar = new jsToolBar($('#{field_id}')); toolbar.draw();}; addEvent(window, \"load\", loadToolbar); ")
  end


end
