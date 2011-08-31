class Abbreviation < ActiveRecord::Base
  acts_as_edition :resources => [:alphabet],
                  :conditions => { :cloneme? => true }
  belongs_to :guide
  belongs_to :alphabet
end
