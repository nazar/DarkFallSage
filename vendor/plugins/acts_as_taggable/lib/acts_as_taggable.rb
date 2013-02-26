module ActiveRecord
  module Acts #:nodoc:
    module Taggable #:nodoc:
      def self.included(base)
        base.extend(ClassMethods)  
      end
      
      module ClassMethods
        def acts_as_taggable(options = {})
          write_inheritable_attribute(:acts_as_taggable_options, {
            :taggable_type => ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s,
            :from => options[:from]
          })
          
          class_inheritable_reader :acts_as_taggable_options

          has_many :taggings, :as => :taggable, :dependent => :destroy
          has_many :tags, :through => :taggings

          include ActiveRecord::Acts::Taggable::InstanceMethods
          extend ActiveRecord::Acts::Taggable::SingletonMethods          
        end
        
        #top tags against this taggable type (ie Photo)
        def top_tags(limit=nil)
          tags = Tag.top_type_tags(self).all :limit => limit
          if tags.length > 0
            tags, min_count, max_count = Tag.sort_min_max_tag_list(tags)
          else
            max_count = 0; min_count = 0; tags = [];
          end
          return tags, min_count, max_count
        end

      end
      
      module SingletonMethods
        def find_tagged_with(list)
          find_by_sql([
            "SELECT #{table_name}.* FROM #{table_name}, tags, taggings " +
            "WHERE #{table_name}.#{primary_key} = taggings.taggable_id " +
            "AND taggings.taggable_type = ? " +
            "AND taggings.tag_id = tags.id AND tags.name IN (?)",
            acts_as_taggable_options[:taggable_type], list
          ])
        end
      end
      
      module InstanceMethods
        
        #this method is destructive and will remove all taggable objects and recreate
        def tag_with(list)
          Tag.transaction do
            taggings.destroy_all

            Tag.parse(list).each do |name|
              if acts_as_taggable_options[:from]
                send(acts_as_taggable_options[:from]).tags.find_or_create_by_name(name).on(self)
              else
                Tag.find_or_create_by_name(name).on(self)
              end
            end
          end
        end
        
        #non destructive
        def tag_with_by_user(list, user)
          Tag.transaction do
            taggings.find_all_by_created_by(user.id).each{|tagging| tagging.destroy}
            
            Tag.parse(list).each do |name|
                taggable = Tag.find_or_create_by_name(name).on(self)
                taggable.created_by = user.id
                taggable.save
            end unless list.blank?
          end
        end
        
        def add_tag_list(list)          
          Tag.transaction do
            Tag.parse(list).each do |name|
              if acts_as_taggable_options[:from]
                send(acts_as_taggable_options[:from]).tags.find_or_create_by_name(name).on(self)
              else
                Tag.find_or_create_by_name(name).on(self)
              end
            end
          end
        end 

        def tag_list
          tags.collect { |tag| tag.name.include?(" ") ? "'#{tag.name}'" : tag.name }.uniqu.join(" ")
        end
        
        def my_tags_objects(user)
          tags.by_user(user)
        end
        
        def my_tag_names(user)
          tags.by_user(user).all(:order => 'tags.name').collect{|tag| tag.name}.uniq.join(', ') if tags
        end

        #this taggable object's top tags, ie Photo.first.top_tags
        def top_tags(limit=nil)
          tag_list = Tag.top_object_tags(self).all :limit => limit
          if tag_list.length > 0
            tags, min_count, max_count = Tag.sort_min_max_tag_list(tag_list)
          else
            max_count = 0; min_count = 0; tags = [];
          end
          return tags, min_count, max_count
        end

        #return similar objects, of the class, that contain the same tags
        def similar_taggables(options = {})
          limit     = options.delete(:limit) || 0
          taggables = []
          tags.sort_by{|tag| tag.name}.each do |tag|
            taggables << tag.taggings.by_type(self.class).collect{|tagging| tagging.taggable_id}
            taggables = taggables.flatten.uniq.select{|target| target != self.id}
            if (limit > 0) && (taggables.length >= limit)
              taggables = taggables[0..limit-1]
              break
            end
          end
          self.class.to_s.constantize.find_all_by_id(taggables)
        end
        
      end
    end
  end
end