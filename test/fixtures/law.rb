class Law < ActiveRecord::Base
  acts_as_edition :edition_chain => [], :resources => '', 
                  :conditions => { :cloneme? => true }
  has_and_belongs_to_many :places

end
