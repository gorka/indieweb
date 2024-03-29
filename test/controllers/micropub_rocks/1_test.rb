require "test_helper"

class MicropubRocks1Test < ActionDispatch::IntegrationTest
  test "100: Create an h-entry post (form-encoded)" do
    data = {
      h: "entry",
      content: "Micropub test of creating a basic h-entry"
    }

    post micropub_path, params: data

    assert_response :created
  end

  test "101: Create an h-entry post with multiple categories (form-encoded)" do
    data = {
      h: "entry",
      content: "Micropub test of creating an h-entry with categories. This post should have two categories, test1 and test2",
      category: [ "test1", "test2" ]
    }

    post micropub_path, params: data

    assert_response :created

    get entry_path(Entry.last)

    assert_select ".h-entry", count: 1
    assert_select ".e-content", text: "Micropub test of creating an h-entry with categories. This post should have two categories, test1 and test2"
    assert_select ".p-category", count: 2
    assert_select ".p-category", text: "test1", count: 1
    assert_select ".p-category", text: "test2", count: 1
  end

  test "104: Create an h-entry with a photo referenced by URL (form-encoded)" do
    data = {
      h: "entry",
      content: "Micropub test of creating a photo referenced by URL",
      photo: "https://micropub.rocks/media/sunset.jpg"
    }

    post micropub_path, params: data

    assert_response :created

    get entry_path(Entry.last)

    assert_select ".h-entry", count: 1
    assert_select ".e-content", text: "Micropub test of creating a photo referenced by URL"
    assert_select 'img[src$="sunset.jpg"]'
  end
end
