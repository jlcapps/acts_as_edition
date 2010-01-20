class Guide < ActiveRecord::Base
  acts_as_edition :edition_chain => [:abbreviation, :imprint, :places],
                  :resources => [:country, :retailers, :authors],
                  :pre_hook => :unpublish_self,
                  :after_clone => :increment_descendant_year,
                  :post_hook => :publish_descendant,
                  :conditions => { :returns_true => true }
  has_one :abbreviation
  belongs_to :imprint
  has_many :places
  has_one :country
  has_many :retailers
  has_and_belongs_to_many :authors

protected

  def unpublish_self
    self.published = false
    self.save!
  end

  def increment_descendant_year
    self.year = (self.year.to_i + 1).to_s
    self.save!
  end

  def publish_descendant
    self.descendant.published = true
    self.descendant.save!
  end

  def returns_true
    name != 'Noclonelandia'
  end
end
