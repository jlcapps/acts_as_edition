class Author < ActiveRecord::Base
  has_and_belongs_to_many :guides
end
