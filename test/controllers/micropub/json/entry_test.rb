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

  test "An entry can have a photo added" do
    uploaded_file = fixture_file_upload("sunset.jpg", "image/jpeg")
    
    stub_request(:get, "https://micropub.rocks/media/sunset.jpg").
      to_return(status: 200, body: uploaded_file.tempfile.read)

    entry = entries(:note)

    update_data = {
      "action": "update",
      "url": entry_url(entry, subdomain: entry.blog.subdomain),
      "add": {
        "photo": ["https://micropub.rocks/media/sunset.jpg"]
      }
    }

    assert_difference "MicroformatPhoto.count", 1 do
      assert_difference "PhotoWithAlt.count", 1 do
        post micropub_url(subdomain: entry.blog.subdomain), params: update_data, as: :json, headers: @headers
      end
    end

    assert_equal entry.microformat_photos.count, 1
    assert_equal entry.photos_with_alt.count, 1
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

  test "An entry can have a photo removed" do
    entry = entries(:with_image_with_alt)

    update_data = {
      "action": "update",
      "url": entry_url(entry, subdomain: entry.blog.subdomain),
      "delete": {
        "photo": [url_for(entry.photos_with_alt.first.photo)]
      }
    }

    assert_difference "MicroformatPhoto.count", -1 do
      assert_difference "PhotoWithAlt.count", -1 do
        post micropub_url(subdomain: entry.blog.subdomain), params: update_data, as: :json, headers: @headers
      end
    end
  end

  test "An entry can have all it's photos removed" do
    entry = entries(:with_image_with_alt)

    update_data = {
      "action": "update",
      "url": entry_url(entry, subdomain: entry.blog.subdomain),
      "delete": ["photo"]
    }

    assert_difference "MicroformatPhoto.count", -2 do
      assert_difference "PhotoWithAlt.count", -2 do
        post micropub_url(subdomain: entry.blog.subdomain), params: update_data, as: :json, headers: @headers
      end
    end
  end
end
