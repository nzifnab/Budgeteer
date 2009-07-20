class Account < ActiveRecord::Base
  belongs_to :prerequisite, :class_name => "Account"
  
  def self.priority_options
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  end
  
  def has_cap?
    if cap != 0
      return true
    else
      return false
    end
  end
  
  def has_prerequisite?
    if prerequisite
      return true
    else
      return false
    end
  end
  
  def has_cap=(value)
    
  end
end
