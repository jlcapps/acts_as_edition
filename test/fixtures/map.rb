class Map < ActiveRecord::Base
  acts_as_edition
  belongs_to :place
end
