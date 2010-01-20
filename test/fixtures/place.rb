class Place < ActiveRecord::Base
  acts_as_edition :edition_chain => [:maps, :laws],
                  :conditions => { :cloneme? => true }
  belongs_to :guide
  has_many :maps
  has_and_belongs_to_many :laws
end
