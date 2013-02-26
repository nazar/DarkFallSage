module NewsHelper

  def truncate_with_more_link(item)
    if item.body.length > 350 #TODO add to Config class
      body = truncate(item.body, 350)
      body << ' - ' << link_to('read more', view_news_path(item))
      #good chance here that HTML is broken due to truncation... run it though HTML TIDY
      Tidy.path = File.join(Rails.root,'bin/libtidy.so')
      body = Tidy.open{|tidy| tidy.options.show_body_only=true; tidy.clean(body)}
    else
      body = item.body
    end
    #TODO need to HTML tidy here
    body
  end

end
