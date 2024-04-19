require "test_helper"

class MicropubJsonEntryTest < ActionDispatch::IntegrationTest
  setup do
    @headers = { "Authorization": "Bearer fake" }

    IndieAuth::TokenVerifier.stubs(:verify).returns([{}, nil])
  end

  test "An entry can have a name" do
    data = {
      "type": ["h-entry"],
      "properties": {
        "name": ["The title"],
        "content": [{ "html": "<div>The content.</div>" }]
      }
    }

    post micropub_url(subdomain: blogs(:valid).subdomain), params: data, as: :json, headers: @headers

    assert_response :created

    get entry_path(Entry.last)

    assert_select ".h-entry", count: 1
    assert_select ".p-name", text: "The title"
    assert_select ".e-content", text: "The content."
  end
end
