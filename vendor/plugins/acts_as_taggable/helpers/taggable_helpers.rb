module ActionView::Helpers::AssetTagHelper

  def object_tag_cloud(object, classes, options={})
    raise "block not given" unless block_given?
    raise "class is not an array. Received #{classes.class.to_s}" unless classes.is_a? Array
    #
    tags, min, max = object.top_tags(options[:limit])
    divisor = ((max - min) / classes.size) + 1
    #
    tags.each { |t|
      yield t, classes[((t.count.to_i - min) / divisor).round]
    }
  end

end