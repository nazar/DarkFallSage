module HomeHelper

  def block_box(options = {}, &block)
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
  
end
