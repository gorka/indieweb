require "test_helper"

class MicropubRocks1Test < ActionDispatch::IntegrationTest
  test "200: Create an h-entry post (JSON)" do
    data = {
      "type": ["h-entry"],
      "properties": {
        "content": ["Micropub test of creating an h-entry with a JSON request"]
      }
    }

    post micropub_path, params: data, as: :json

    assert_response :created

    get entry_path(Entry.last)

    assert_select ".h-entry", count: 1
    assert_select ".e-content", text: "Micropub test of creating an h-entry with a JSON request"
  end

  test "201: Create an h-entry post with multiple categories (JSON)" do
    data = {
      "type": ["h-entry"],
      "properties": {
        "content": ["Micropub test of creating an h-entry with a JSON request containing multiple categories. This post should have two categories, test1 and test2."],
        "category": [
          "test1",
          "test2"
        ]
      }
    }

    post micropub_path, params: data, as: :json

    assert_response :created

    get entry_path(Entry.last)

    assert_select ".h-entry", count: 1
    assert_select ".e-content", text: "Micropub test of creating an h-entry with a JSON request containing multiple categories. This post should have two categories, test1 and test2."
    assert_select ".p-category", count: 2
    assert_select ".p-category", text: "test1", count: 1
    assert_select ".p-category", text: "test2", count: 1
  end

  test "202: Create an h-entry with HTML content (JSON)" do
    data = {
      "type": ["h-entry"],
      "properties": {
        "content": [{
          "html": "<p>This post has <b>bold</b> and <i>italic</i> text.</p>"
        }]
      }
    }

    post micropub_path, params: data, as: :json

    assert_response :created

    get entry_path(Entry.last)

    assert_select ".h-entry", count: 1
    assert_select ".e-content", content: "<p>This post has <b>bold</b> and <i>italic</i> text.</p>"
  end
end
