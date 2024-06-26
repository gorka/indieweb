require "test_helper"

class MicropubRocks1Test < ActionDispatch::IntegrationTest
  setup do
    @headers = { "Authorization": "Bearer fake" }

    IndieAuth::TokenVerifier.stubs(:verify).returns([{}, nil])
  end

  test "200: Create an h-entry post (JSON)" do
    data = {
      "type": ["h-entry"],
      "properties": {
        "content": ["Micropub test of creating an h-entry with a JSON request"]
      }
    }

    post micropub_url(subdomain: blogs(:valid).subdomain), params: data, as: :json, headers: @headers

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

    post micropub_url(subdomain: blogs(:valid).subdomain), params: data, as: :json, headers: @headers

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

    post micropub_url(subdomain: blogs(:valid).subdomain), params: data, as: :json, headers: @headers

    assert_response :created

    get entry_path(Entry.last)

    assert_select ".h-entry", count: 1
    assert_select ".e-content", content: "<p>This post has <b>bold</b> and <i>italic</i> text.</p>"
  end

  test "203: Create an h-entry with a photo referenced by URL (JSON)" do
    uploaded_file = fixture_file_upload("sunset.jpg", "image/jpeg")
    
    stub_request(:get, "https://micropub.rocks/media/sunset.jpg").
      to_return(status: 200, body: uploaded_file.tempfile.read)

    data = {
      "type": ["h-entry"],
      "properties": {
        "content": ["Micropub test of creating a photo referenced by URL. This post should include a photo of a sunset."],
        "photo": ["https://micropub.rocks/media/sunset.jpg"]
      }
    }

    post micropub_url(subdomain: blogs(:valid).subdomain), params: data, as: :json, headers: @headers

    assert_response :created

    get entry_path(Entry.last)

    assert_select ".h-entry", count: 1
    assert_select ".e-content", text: "Micropub test of creating a photo referenced by URL. This post should include a photo of a sunset."
    assert_select 'img[src$="sunset.jpg"]'
  end

  test "205: Create an h-entry post with a photo with alt text (JSON)" do
    uploaded_file = fixture_file_upload("sunset.jpg", "image/jpeg")
    
    stub_request(:get, "https://micropub.rocks/media/sunset.jpg").
      to_return(status: 200, body: uploaded_file.tempfile.read)

    data = {
      "type": ["h-entry"],
      "properties": {
        "content": ["Micropub test of creating a photo referenced by URL with alt text. This post should include a photo of a sunset."],
        "photo": [
          {
            "value": "https://micropub.rocks/media/sunset.jpg",
            "alt": "Photo of a sunset"
          }
        ]
      }
    }

    post micropub_url(subdomain: blogs(:valid).subdomain), params: data, as: :json, headers: @headers

    assert_response :created

    get entry_path(Entry.last)

    assert_select ".h-entry", count: 1
    assert_select ".e-content", text: "Micropub test of creating a photo referenced by URL with alt text. This post should include a photo of a sunset."
    assert_select 'img[alt$="Photo of a sunset"]'
  end
end
