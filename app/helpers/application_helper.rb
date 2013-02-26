# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def render_object_errors(obj, message="There was a problem processing this form.")
    if obj.errors && obj.errors.length > 0
      markaby do
        tag! :div, :id => 'errorExplanation', :class => 'errorExplanation' do
          h2 message
          ul do
            obj.errors.each do |field, error|
              li "#{field.humanize} #{error}"
            end
          end
        end
      end
    end
  end

  def markaby(&block)
    Markaby::Builder.new({}, self, &block)
  end

  def markaby_to_s(&block)
    Markaby::Builder.new({}, self, &block).to_s
  end

  def add_extra_header_content(content = nil, &block)
    @extra_header_content ||= ''
    if block_given?
      @extra_header_content << block.call.to_s << ' '
    else
      @extra_header_content << content << ' '
    end
  end

  def get_extra_header_content
    @extra_header_content ||= ''
    @extra_header_content
  end

  def add_footer_sript(script = nil, &block)
    @last_scripts ||= ''
    if block_given?
      @last_scripts << block.call.to_s << ' '
    else
      @last_scripts << script << ' '
    end
  end

  def get_footer_script
    @last_scripts ||= '';
    @last_scripts
  end

  def jquery_include_tag(*libs)
    js_libs = []
    js_opts = {}
    libs.each do |library|
      case
        when library.is_a?(String)
          js_libs << "jquery/#{library}"
        when library.is_a?(Hash)
          js_opts.merge!(library)
      end
    end
    javascript_include_tag js_libs, js_opts
  end

 #options[:escape] - element of tags to escape i.e. (['pre','code']) or a string for a single element ie ('pre')
  def format_red_cloth(body, options={})
    unless body.blank?
      #escape and textalise
      rc = RedCloth.new(body, [:filter_html, :filter_styles])
      white_list(rc.to_html)
    end
  end

  def header_logo_class
    session[:logo] = 1 if session[:logo].nil?
    session[:logo_counter] = 1 if session[:logo_counter].nil?
    session[:logo_counter] += 1
    if session[:logo_counter] > 6
      session[:logo_counter] = 1
      session[:logo] += 1
      session[:logo] = 1 if session[:logo] > 8
    end
    "logo#{session[:logo]}"
  end

  #options: :header, :id
  def content_block(title, options = {}, &block)
    options[:header] ||= 'h3'
    options[:id] = options[:id].blank? ? '' : "id='#{options[:id]}'"
    result = '<div class="site_block">'
    result << "<#{options[:header]} class='ui-widget-header ui-corner-top'>#{title}</#{options[:header]}>"
    if block_given?
      result << "<div class='ui-widget ui-widget-content ui-corner-bottom' #{options[:id]}>"
      result << capture(&block)
      result << '<br clear="all"/>'
      result << '</div>'
    end
    result << '</div>'
    concat(result, block.binding)
  end

  def forum_type_to_link(topic)
    case
      when topic.topicable_type == 'Forum';
        link_to 'Forums', forum_path(topic.topicable_id)
      when topic.topicable_type == 'Mob';
        link_to 'Mob', forum_path(topic.topicable_id)
      when topic.topicable_type == 'Item';
        link_to 'Item', item_path(topic.topicable_id)
      when topic.topicable_type == 'Skill';
        link_to 'Skill', skill_path(topic.topicable_id)
      when topic.topicable_type == 'Spell';
        link_to 'Spell', spell_path(topic.topicable_id)
      when topic.topicable_type == 'Image';
        link_to 'Image', image_path(topic.topicable_id)
      when topic.topicable_type == 'Article'
        link_to 'Article', article_path(topic.topicable_id)
      when topic.topicable_type == 'ClanForum'
        link_to 'Clan', clan_forum_path(topic.topicable_id)
      when topic.topicable_type == 'News'
        link_to 'News', news_path(topic.topicable_id)
    end
  end

  #options - :id - table id
  def sortable_table(options={}, &block)
    raise "Must specify block" unless block_given?
    options[:id] ||= 'sortable'
    id = "id='#{options[:id]}'"
    #
    result = "<table #{id} cellpadding=\"0\" cellspacing=\"0\" class=\"sortable\">"
    result << capture(&block)
    result << '</table>'
    result << javascript_tag("SortableTable.init('#{options[:id]}');")
    concat(result, block.binding)
  end

  def rails_in_development
    RAILS_ENV == 'development'
  end

  def show_advertising
    if current_user.blank?
      result = true
    else
      result = (not admin?) && (current_user.counter.reputation < Reputation::NoAdverts) 
    end
    result && (not rails_in_development)
  end

end
