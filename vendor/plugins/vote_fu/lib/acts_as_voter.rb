# ActsAsVoter
module PeteOnRails
  module Acts #:nodoc:
    module Voter #:nodoc:

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods

        def acts_as_voter(options={})
          options[:class] ||= 'Vote'
          options[:dependant] ||= :nullify
          #
          write_inheritable_attribute(:acts_as_voter_options, {
            :class            => options[:class],
            :klass            => options[:class].constantize       
          })
          class_inheritable_reader :acts_as_voter_options
          #
          has_many :votes, :as => :voter, :dependent => :nullify  # If a voting entity is deleted, keep the votes. 
          include PeteOnRails::Acts::Voter::InstanceMethods
          extend  PeteOnRails::Acts::Voter::SingletonMethods
        end

      end
      
      # This module contains class methods
      module SingletonMethods
      end
      
      # This module contains instance methods
      module InstanceMethods
        
        # Usage user.vote_count(true)  # All +1 votes
        #       user.vote_count(false) # All -1 votes
        #       user.vote_count()      # All votes
        
        def vote_count(for_or_against = "all")
          where = (for_or_against == "all") ? 
            ["voter_id = ? AND voter_type = ?", id, self.class.base_class.name ] :
            ["voter_id = ? AND voter_type = ? AND vote = ?", id, self.class.base_class.name, for_or_against ]
                        
          acts_as_voter_options[:klass].count(:all, :conditions => where)

        end
                
        def voted_for?(voteable)
           0 < acts_as_voter_options[:klass].count(:all, :conditions => [
                   "voter_id = ? AND voter_type = ? AND vote = ? AND voteable_id = ? AND voteable_type = ?",
                   self.id, self.class.base_class.name, true, voteable.id, voteable.class.base_class.name
                   ])
         end

         def voted_against?(voteable)
           0 < acts_as_voter_options[:klass].count(:all, :conditions => [
                   "voter_id = ? AND voter_type = ? AND vote = ? AND voteable_id = ? AND voteable_type = ?",
                   self.id, self.class.base_class.name, false, voteable.id, voteable.class.base_class.name
                   ])
         end

         def voted_on?(voteable)
           0 < acts_as_voter_options[:klass].count(:all, :conditions => [
                   "voter_id = ? AND voter_type = ? AND voteable_id = ? AND voteable_type = ?",
                   self.id, self.class.base_class.name, voteable.id, voteable.class.base_class.name
                   ])
         end
                
        def vote_for(voteable)
          self.vote(voteable, true)
        end
        
        def vote_against(voteable)
          self.vote(voteable, false)
        end

        def vote(voteable, vote)
          vote = acts_as_voter_options[:klass].new(:vote => vote, :voteable => voteable, :voter => self)
          vote.save
        end

      end
    end
  end
end
