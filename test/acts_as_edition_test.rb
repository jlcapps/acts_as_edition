require 'test_helper'

class ActsAsEditionTest < ActiveSupport::TestCase
  fixtures :all

  test "should respond to #ancestor" do
    assert_respond_to Guide.new, :ancestor
  end

  test "should respond to #descendant" do
    assert_respond_to Guide.new, :descendant
  end

  test "#ancestor and #descendant work as expected" do
    guide = guides(:scotland)
    cloned = guide.clone
    cloned.ancestor = guide
    cloned.save!
    assert_equal cloned.ancestor, guide
    assert_equal guide.descendant, cloned
  end

  test "should respond to #clone_edition!" do
    assert_respond_to guides(:scotland), :clone_edition!
  end

  test "#clone_edition! clones edition" do
    orig = guides(:scotland)
    cloned = orig.clone_edition!
    assert_equal cloned.ancestor, orig
    assert_equal orig.descendant, cloned
    assert_equal orig.name, cloned.name
  end

  test ":edition_chain and :resources options are stored as class attrs" do
    assert_respond_to guides(:scotland), :edition_chain
    assert guides(:scotland).edition_chain.include? :abbreviation
    assert_respond_to Law.new, :resources
  end

  test "guide and abbreviation are properly related" do
    assert_equal guides(:scotland).abbreviation, abbreviations(:sco)
  end

  test "should clone has_one specified in edition_chain" do
    orig = guides(:scotland)
    cloned = orig.clone_edition!
    assert_equal orig.abbreviation, cloned.abbreviation.ancestor
    assert_equal orig.abbreviation.descendant, cloned.abbreviation
  end

  test "should clone belongs_to specified in edition_chain" do
    orig = guides(:scotland)
    cloned = orig.clone_edition!
    orig.reload
    cloned.reload
    assert_equal orig.imprint, orig.descendant.imprint.ancestor
    assert_equal cloned.imprint, orig.imprint.descendant
    assert orig.imprint.descendant.guides.include? orig.descendant
  end

  test "should clone has_manys specified in edition_chain" do
    orig = guides(:scotland)
    cloned = orig.clone_edition!
    orig.reload
    cloned.reload
    orig.places.each do |place|
      assert cloned.places.include? place.descendant
      assert_equal place.descendant.guide, cloned
    end
    cloned.places.each do |place|
      assert orig.places.include? place.ancestor
      assert_equal place.ancestor.guide, orig
    end 
  end

  test "should clone nested has_manys" do
    orig = guides(:scotland)
    cloned = orig.clone_edition!
    orig.reload
    cloned.reload
    orig_maps_count = cloned_maps_count = 0
    orig.places.each { |place| orig_maps_count += place.maps.count }
    cloned.places.each { |place| cloned_maps_count += place.maps.count }
    assert_equal orig_maps_count, cloned_maps_count
    cloned.places.each do |place|
      place.maps.each do |map|
        assert place.ancestor.maps.include? map.ancestor
      end
    end
  end

  test "should clone has_and_belongs_to_manys specified in edition_chain" do
    orig = guides(:scotland)
    cloned = orig.clone_edition!
    orig.reload
    cloned.reload
    orig_laws = cloned_laws = []
    orig.places.each { |place| orig_laws += place.laws }
    cloned.places.each { |place| cloned_laws += place.laws }
    assert_equal orig_laws.count, cloned_laws.count
    orig_laws.each do |orig_law|
      assert_equal 1, Law.find_all_by_ancestor_id(orig_law.id).count
      assert !cloned_laws.include?(orig_law)
      assert cloned_laws.include?(orig_law.descendant)
      orig_law.places.each do |orig_place|
        assert !orig_law.descendant.places.include?(orig_place)
      end
    end
    cloned_laws.each do |cloned_law|
      assert orig_laws.include?(cloned_law.ancestor)
    end
  end

  test "should update relationship to has_ones spec'd in resources" do
    # XXX this is a contrived case; would probably want to clone . . .
    orig = guides(:scotland)
    country = orig.country
    cloned = orig.clone_edition!
    orig.reload
    cloned.reload 
    assert_equal orig.country, nil
    assert_equal cloned.country, country
  end

  test "should updated relationship to has_manys spec'd in resources" do
    orig = guides(:scotland)
    retailer_ids = orig.retailers.collect { |r| r.id }
    cloned = orig.clone_edition!
    orig.reload
    assert_equal 0, orig.retailers.count
    assert_equal retailer_ids.count, cloned.retailers.count
    cloned.retailers.each do |retailer|
      assert retailer_ids.include?(retailer.id)
    end
    cloned_ids = cloned.retailers.collect { |r| r.id }
    retailer_ids.each do |id|
      assert cloned_ids.include?(id)
    end
  end

  test "should update relationship to has_and_belongs_to_many resources" do
    # habtm realtionships are handled differently from other resources.
    # For the resource, the change is additive. The resource will have
    # a relationship with original *and* cloned edition object.
    orig = guides(:scotland)
    author_ids = orig.authors.collect { |a| a.id }
    cloned = orig.clone_edition!
    orig.reload
    assert_equal cloned.authors.count, orig.authors.count
    assert_equal cloned.authors.first.guides.count, 2
    orig.authors.each { |author| assert cloned.authors.include?(author) }
    cloned.authors.each { |author| assert orig.authors.include?(author) }
  end

  test "should execute pre_hook" do
    orig = guides(:scotland)
    assert orig.published?
    cloned = orig.clone_edition!
    orig.reload
    assert !orig.published?
  end

  test "should execute after_clone" do
    orig = guides(:scotland)
    orig_year = orig.year.to_i
    cloned = orig.clone_edition!
    orig.reload
    assert_equal orig_year + 1, cloned.year.to_i
    assert_equal orig.year.to_i, orig_year
  end

  test "should execute post_hook" do
    orig = guides(:scotland)
    cloned = orig.clone_edition!
    orig.reload
    assert !orig.published?
    assert cloned.published?
  end
end
