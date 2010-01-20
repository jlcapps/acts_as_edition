class Abbreviation < ActiveRecord::Base
  acts_as_edition :conditions => { :cloneme? => true }
  belongs_to :guide
end
