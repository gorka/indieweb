require "application_system_test_case"

class EntriesTest < ApplicationSystemTestCase
  test "should get an entry with microformats without categories" do
    entry = entries(:without_categories)

    visit entry_path(entry)

    assert_selector ".h-entry", count: 1
    assert_selector ".e-content", text: "Entry without categories"
    assert_selector ".p-category", count: 0
  end

  test "should get an entry with microformats with categories" do
    entry = entries(:with_categories)

    visit entry_path(entry)

    assert_selector ".h-entry", count: 1
    assert_selector ".e-content", text: "Entry with categories"
    assert_selector ".p-category", count: 2
    assert_selector ".p-category", text: "Category1", count: 1
    assert_selector ".p-category", text: "Category2", count: 1
  end
end
