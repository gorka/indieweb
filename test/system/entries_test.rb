require "application_system_test_case"

class EntriesTest < ApplicationSystemTestCase
  test "should get an entry with microformats" do
    entry = entries(:one)

    visit entry_path(entry)

    assert_selector ".h-entry", count: 1
    assert_selector ".e-content", text: "MyText"
  end
end
