class SlugCache

  @cache = {}

  def self.register_cache(klass, options = {})
    raise "Block must be given" unless block_given?
    options[:name] ||= klass.base_class.to_s
    options[:id] ||= 'id'
    #
    fields = yield
    return if fields.blank?
    #iterate through fields and get ids
    ids = []
    if fields.is_a?(Array)
      fields.each do |row|
        ids << row.send("#{options[:id]}")
      end
    else
      ids << fields.send(options[:id])
    end
    #remove existing ids from calc-ed list
    @cache[options[:name]].keys{|id| ids.delete(id)} unless @cache[options[:name]].blank?
    #query slugs for for missing ids
    hslugs = {}
    Slug.find(:all, :conditions => {:sluggable_type => klass.base_class.to_s, :sluggable_id => ids}).each do |slug|
      #re-arrange hash into [klass][id] = row
      hslugs[slug.sluggable_id] = slug
    end
    @cache[options[:name]] = {} if @cache[options[:name]].nil?
    @cache[options[:name]].merge!(hslugs)
    #
    fields
  end

  def self.query_cache(klass, id, options={})
    options[:name] ||= klass.base_class.to_s
    options[:id] ||= 'id'

    if (not @cache[options[:name]].blank?) && result = @cache[options[:name]][id]
      RAILS_DEFAULT_LOGGER.debug "SlugCache HIT: #{klass.to_s} - #{id.to_s}"
      result
    else
      RAILS_DEFAULT_LOGGER.debug "SlugCache MISS: #{klass.to_s} - #{id.to_s}"
      nil
    end
  end

  def self.clear_cache(klass=nil)
    if klass.nil?
      @cache.clear
      @cache = {}
    else
      @cache.delete(klass.base_class.to_s)
    end
     RAILS_DEFAULT_LOGGER.debug "SlugCache CLEARED"
  end

end