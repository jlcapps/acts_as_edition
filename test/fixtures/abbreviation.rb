class Abbreviation < ActiveRecord::Base
  acts_as_edition
  belongs_to :guide
end
