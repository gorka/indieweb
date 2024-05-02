require "test_helper"

class MicropubRocks1Test < ActionDispatch::IntegrationTest
  setup do
    @headers = { "Authorization": "Bearer fake" }

    IndieAuth::TokenVerifier.stubs(:verify).returns([{}, nil])
  end

  test "100: Create an h-entry post (form-encoded)" do
    data = {
      h: "entry",
      content: "Micropub test of creating a basic h-entry"
    }

    post micropub_url(subdomain: blogs(:valid).subdomain), params: data, headers: @headers

    assert_response :created
  end

  test "101: Create an h-entry post with multiple categories (form-encoded)" do
    data = {
      h: "entry",
      content: "Micropub test of creating an h-entry with categories. This post should have two categories, test1 and test2",
      category: [ "test1", "test2" ]
    }

    post micropub_url(subdomain: blogs(:valid).subdomain), params: data, headers: @headers

    assert_response :created

    get entry_path(Entry.last)

    assert_select ".h-entry", count: 1
    assert_select ".e-content", text: "Micropub test of creating an h-entry with categories. This post should have two categories, test1 and test2"
    assert_select ".p-category", count: 2
    assert_select ".p-category", text: "test1", count: 1
    assert_select ".p-category", text: "test2", count: 1
  end

  test "104: Create an h-entry with a photo referenced by URL (form-encoded)" do
    uploaded_file = fixture_file_upload("sunset.jpg", "image/jpeg")
    
    stub_request(:get, "https://micropub.rocks/media/sunset.jpg").
      to_return(status: 200, body: uploaded_file.tempfile.read)

    data = {
      h: "entry",
      content: "Micropub test of creating a photo referenced by URL",
      photo: "https://micropub.rocks/media/sunset.jpg"
    }

    post micropub_url(subdomain: blogs(:valid).subdomain), params: data, headers: @headers

    assert_response :created

    get entry_path(Entry.last)

    assert_select ".h-entry", count: 1
    assert_select ".e-content", text: "Micropub test of creating a photo referenced by URL"
    assert_select 'img[src$="sunset.jpg"]'
  end

  test "107: Create an h-entry post with one category (form-encoded)" do
    data = {
      h: "entry",
      content: "Micropub test of creating an h-entry with one category. This post should have one category, test1",
      category: "test1"
    }

    post micropub_url(subdomain: blogs(:valid).subdomain), params: data, headers: @headers

    assert_response :created

    get entry_path(Entry.last)

    assert_select ".h-entry", count: 1
    assert_select ".e-content", text: "Micropub test of creating an h-entry with one category. This post should have one category, test1"
    assert_select ".p-category", count: 1
    assert_select ".p-category", text: "test1", count: 1
  end
end
