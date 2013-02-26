module ProfilesHelper

  def profile_image(user)
    if user.profile_image.nil?
      image_tag 'no_avatar_l.gif'
    else
      image_tag user.profile_image.url
    end
  end

  def forum_avatar(user)
    if user.avatar.nil?
      image_tag 'no_avatar_s.gif'
    else
      image_tag user.avatar.url
    end
  end  

  def render_exist_light_row(title, field, value = nil)
    unless field.blank?
      markaby do
        tr do
          td.light_cell title
          td value.blank? ? h(field) : value
        end
      end
    end
  end

  def profile_box(options = {}, &block)
    header_type  = options[:header_type]  || :h3
    title        = options[:title]        || ''
    header_link  = options[:header_link].nil? ? '' : content_tag(:span, options[:header_link], :class => 'small_side_notes')
    header = header_link << title
    block_class = {}; block_class[:class]  = options[:block_class]  || nil
    #
    cap = capture do
      content_tag(:div, content_tag(header_type, header, :class => 'normal_header' ) << capture(&block), block_class)
    end
    concat(cap, block.binding)
  end

  def profile_navbar(active = :details)
#    menus   = [[:details, :edit], :images, :comments, :settings, :notifications]
    menus   = [[:details, :edit], :images]
    li      = ''
    #
    menus.each do |menu|
      if menu.is_a? Array
        action = menu.last
        menu   = menu.first
      else
        action = menu
      end
      #
      options = {}
      options[:class] = 'horiznav_active' if menu == active
      li << content_tag(:li, link_to(menu.to_s.capitalize, {:controller => 'profiles', :action => action, :login => current_user.login}, options))
    end
    content_tag(:div, content_tag(:ul, li, :style => 'margin-right: 0pt; padding-right: 0pt;'), :id => 'horiznav_nav')
  end
  

end
