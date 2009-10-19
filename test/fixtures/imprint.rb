class Imprint < ActiveRecord::Base
  acts_as_edition
  has_many :guides
end
