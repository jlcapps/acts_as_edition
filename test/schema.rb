ActiveRecord::Schema.define(:version => 1) do
  create_table :guides, :force => true do |t|
    t.column :name, :string
    t.column :ancestor_id, :integer, :default => nil
    t.column :imprint_id, :integer, :default => nil
    t.column :published, :boolean, :default => false
    t.column :year, :string
  end
  
  create_table :places, :force => true do |t|
    t.column :name, :string
    t.column :guide_id, :integer
    t.column :ancestor_id, :integer, :default => nil
    t.column :cloneme, :boolean, :default => true
  end

  create_table :laws, :force => true do |t|
    t.column :name, :string
    t.column :ancestor_id, :integer, :default => nil
    t.column :cloneme, :boolean, :default => true
  end

  create_table "laws_places", :id => false, :force => true do |t|
    t.integer "place_id"
    t.integer "law_id"
  end
   
  create_table :maps, :force => true do |t|
    t.column :name, :string
    t.column :place_id, :integer
    t.column :ancestor_id, :integer, :default => nil
  end

  create_table :abbreviations, :force => true do |t|
    t.column :name, :string
    t.column :guide_id, :integer
    t.column :ancestor_id, :integer, :default => nil
    t.column :cloneme, :boolean, :default => true
  end 

  create_table :imprints, :force=> true do |t|
    t.column :name, :string
    t.column :ancestor_id, :integer, :default => nil
  end

  create_table :countries, :force=> true do |t|
    t.column :name, :string
    t.column :guide_id, :integer, :default => nil
  end

  create_table :retailers, :force=> true do |t|
    t.column :name, :string
    t.column :guide_id, :integer, :default => nil
  end

  create_table :authors, :force=> true do |t|
    t.column :name, :string
  end

  create_table "authors_guides", :id => false, :force => true do |t|
    t.integer "author_id"
    t.integer "guide_id"
  end
 end
