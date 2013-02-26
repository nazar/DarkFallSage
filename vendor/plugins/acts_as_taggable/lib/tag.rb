class Tag < ActiveRecord::Base

  has_many :taggings

  named_scope :top_object_tags, lambda{|object|
    {
      :select => 'tags.name, count(tags.name) count', :from => 'taggings',
      :joins => 'inner join tags on taggings.tag_id = tags.id',
      :conditions => ['taggings.taggable_id = ? and taggings.taggable_type = ?', object.id, object.class.to_s.constantize.base_class.to_s],
      :group => 'tags.name',
      :order => 'count DESC, tags.name'
    }
  }

  named_scope :top_type_tags, lambda{|klass|
    {
      :select => 'tags.name, count(tags.name) count', :from => 'taggings',
      :joins => 'inner join tags on taggings.tag_id = tags.id',
      :conditions => ['taggings.taggable_type = ?', klass.to_s.constantize.base_class.to_s],
      :group => 'tags.name',
      :order => 'count DESC, tags.name'
    }
  }

  named_scope :by_user, lambda{|user|
    {:conditions => ['tags.id in (select taggings.tag_id from taggings where taggings.created_by = ?)', user.id]}
  }

  named_scope :by_user_and_type, lambda{|user, klass|
    {:conditions => ['tags.id in (select taggings.tag_id from taggings where taggings.created_by = ? and taggings.taggable_type = ?)',
        user.id, klass.to_s.constantize.base_class.to_s]}
  }

  #class methods

  def self.parse(list)
    tag_names = []
    unless list.blank?
      #downcase all tags
      list.downcase!
      # first, pull out the quoted tags
      list.gsub!(/\"(.*?)\"\s*/ ) { tag_names << $1; "" }

      # then, replace all commas with a space
      list.gsub!(/,/, " ")

      # then, get whatever's left
      tag_names.concat list.split(/\s/)

      # strip whitespace from the names
      tag_names = tag_names.map { |t| t.strip }

      # delete any blank tag names
      tag_names = tag_names.delete_if { |t| t.empty? }
    end
    
    return tag_names
  end

  def self.sort_min_max_tag_list(tags)
    max_count = tags.first.count
    min_count = tags.last.count
    #sort list alphabetically
    tags = tags.sort{|x,y| x.name <=> y.name }
    #
    return tags, min_count.to_i, max_count.to_i
  end


  def tagged
    @tagged ||= taggings.collect { |tagging| tagging.taggable }
  end
  
  def on(taggable)
    taggings.create :taggable => taggable
  end
  
  def ==(comparison_object)
    super || name == comparison_object.to_s
  end
  
  def to_s
    name
  end

end