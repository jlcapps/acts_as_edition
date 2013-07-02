# ActsAsEdition
module ActsAsEdition
   # :pre_hook and :post_hook run on the original object. :after_clone
   # runs on the cloned object before it is saved.
   # Attributes listed in :edition_chain are cloned and related to
   # self.descendant. Those listed in :resources are related to the
   # self.descendant and are otherwise left as is.
   # NOTE: habtm realtionships are handled differently from other
   # resources. For the resource, the change is additive. The resource
   # will have a relationship with original *and* cloned edition object.
   def acts_as_edition(options = {})
    belongs_to :ancestor, :class_name => name, :foreign_key => :ancestor_id
    has_one :descendant, :class_name => name, :foreign_key => :ancestor_id

    cattr_accessor :edition_chain, :resources, :pre_hook, :after_clone,
                   :post_hook, :conditions
    self.edition_chain = Array((options[:edition_chain] || []))
    self.resources = Array((options[:resources] || []))
    self.pre_hook = options[:pre_hook]
    self.after_clone = options[:after_clone]
    self.post_hook = options[:post_hook]
    self.conditions = (options[:conditions] || {})

    include InstanceMethods
  end

  module InstanceMethods
    def clone_edition!
      self.class.transaction do
        self.send("#{self.pre_hook}") if self.pre_hook
        cloned = self.dup
        cloned.send("#{self.after_clone}") if self.after_clone
        cloned.ancestor = self
        cloned.save!
        self.reload
        clone_edition_chain
        clone_resource_chain
        self.send("#{self.post_hook}") if self.post_hook
        cloned.save!
        cloned.reload
      end if aae_conditions_met
    end

  protected

    def aae_conditions_met
      self.conditions.keys.collect do |k|
        self.send(k) == self.conditions[k]
      end.all?
    end

    def clone_edition_chain
      self.edition_chain.each do |association|
        case self.class.reflect_on_association(association).macro
        when :has_one, :belongs_to
          cloned = (self.send(association) &&
                    (self.send(association).descendant ||
                     self.send(association).clone_edition!))
          self.descendant.send("#{association}=", cloned) unless cloned.nil?
          self.descendant.save!
        when :has_many, :has_and_belongs_to_many
          self.send(association) && self.send(association).each do |associated|
            cloned = associated.descendant || associated.clone_edition!
            unless (self.descendant.send("#{association}").include?(cloned) ||
                    cloned.nil?)
              self.descendant.send("#{association}") << cloned
              self.descendant.save!
            end
          end
       end
      end
    end

    def clone_resource_chain
      self.reload
      self.resources.reject { |r| r.to_s.empty? }.each do |association|
        case self.class.reflect_on_association(association).macro
        when :has_one
          resource = self.send(association)
          self.descendant.send("#{association}=", resource)
          self.descendant.save!
        when :has_many, :has_and_belongs_to_many
          resources = self.send(association)
          resources.each do |resource|
            self.descendant.send("#{association}") << resource
          end
          self.descendant.save!
        end
      end
    end
  end
end

ActiveRecord::Base.extend ActsAsEdition

