class UserCounter < ActiveRecord::Base

  belongs_to :user

  named_scope :top_reputation, lambda{|limit| limit ||= 5
    {:order => 'reputation DESC', :limit => limit}
  }

  #instance methods

  def update_counter(counter, delta)
    counter = "#{counter}_count"
    if delta > 0
      self.send("#{counter}=", self.send("#{counter}").to_i + 1)
    else
      self.send("#{counter}=", self.send("#{counter}").to_i - 1) if self.send("#{counter}") > 0
    end
  end  

end
