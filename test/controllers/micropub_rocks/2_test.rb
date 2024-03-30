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
end
