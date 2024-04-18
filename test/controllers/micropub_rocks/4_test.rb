require "test_helper"

class MicropubRocks4Test < ActionDispatch::IntegrationTest
  setup do
    @headers = { "Authorization": "Bearer fake" }

    IndieAuth::TokenVerifier.stubs(:verify).returns([{}, nil])
  end

  test "400: Replace a property" do
    # Create entry
    blog = blogs(:valid)
    data = {
      "type": ["h-entry"],
      "properties": {
        "content": ["Micropub update test. This text should be replaced if the test succeeds."]
      }
    }

    post micropub_url(subdomain: blog.subdomain), params: data, as: :json, headers: @headers

    assert_response :created

    #Update entry:

    last_entry = Entry.last

    update_data = {
      "action": "update",
      "url": entry_url(last_entry),
      "replace": {
        "content": ["This is the updated text. If you can see this you passed the test!"]
      }
    }

    post micropub_url(subdomain: blog.subdomain), params: update_data, as: :json, headers: @headers

    get entry_path(last_entry)

    assert_select ".e-content", text: "This is the updated text. If you can see this you passed the test!"
  end
end
