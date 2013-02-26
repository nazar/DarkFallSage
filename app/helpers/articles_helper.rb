module ArticlesHelper

  def truncate_article_with_more_link(article)
    if article.body.length > 350 #TODO add to Config class
      body = truncate(article.body, 150)
      body << ' - ' << link_to('read more', article_view_path(article.id, article.title.to_permalink))
      #good chance here that HTML is broken due to truncation... run it though HTML TIDY
      Tidy.path = File.join(Rails.root,'bin/libtidy.so')
      body = Tidy.open{|tidy| tidy.options.show_body_only=true; tidy.clean(body)}
    else
      body = article.body
    end
    body
  end
  

end
