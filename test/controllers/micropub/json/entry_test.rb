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

  test "An entry can have it's name updated" do
    blog = blogs(:valid)
    data = {
      "type": ["h-entry"],
      "properties": {
        "name": ["The title to be updated"],
        "content": [{ "html": "<div>The content.</div>" }]
      }
    }

    post micropub_url(subdomain: blog.subdomain), params: data, as: :json, headers: @headers

    assert_response :created

    get entry_path(Entry.last)

    assert_select ".h-entry", count: 1
    assert_select ".p-name", text: "The title to be updated"

    # Update entry:

    last_entry = Entry.last

    update_data = {
      "action": "update",
      "url": entry_url(last_entry),
      "replace": {
        "name": ["The updated title"]
      }
    }

    post micropub_url(subdomain: blog.subdomain), params: update_data, as: :json, headers: @headers

    get entry_url(last_entry)

    assert_select ".p-name", text: "The updated title"
  end

  test "An entry can have it's name removed" do
    blog = blogs(:valid)
    data = {
      "type": ["h-entry"],
      "properties": {
        "name": ["The title to be removed"],
        "content": [{ "html": "<div>The content.</div>" }]
      }
    }

    post micropub_url(subdomain: blog.subdomain), params: data, as: :json, headers: @headers

    assert_response :created

    get entry_path(Entry.last)

    assert_select ".h-entry", count: 1
    assert_select ".p-name", text: "The title to be removed"

    # Update entry:

    last_entry = Entry.last

    update_data = {
      "action": "update",
      "url": entry_url(last_entry),
      "delete": ["name"]
    }

    post micropub_url(subdomain: blog.subdomain), params: update_data, as: :json, headers: @headers

    get entry_url(last_entry)

    assert_select ".p-name", false
  end
end
