class AddEditionMigration < ActiveRecord::Migration
  def self.up
  <% args.each do |a| -%>
    add_column :<%= a %>, :ancestor_id, :integer
  <% end -%>
  end

  def self.down
  <% args.each do |a| -%>
    remove_column :<%= a %>, :ancestor_id
  <% end -%>
  end
end
