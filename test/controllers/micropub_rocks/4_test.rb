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

    get entry_url(last_entry)

    assert_select ".e-content", text: "This is the updated text. If you can see this you passed the test!"
  end

  test "401: Add a value to an existing property" do
    # Create entry
    blog = blogs(:valid)
    data = {
      "type": ["h-entry"],
      "properties": {
        "content": ["Micropub update test for adding a category. After you run the update, this post should have two categories: test1 and test2."],
        "category": ["test1"]
      }
    }

    post micropub_url(subdomain: blog.subdomain), params: data, as: :json, headers: @headers

    assert_response :created

    last_entry = Entry.last
    get entry_url(last_entry)

    assert_select ".p-category", count: 1
    assert_select ".p-category", text: "test1", count: 1

    #Update entry:

    update_data = {
      "action": "update",
      "url": entry_path(last_entry),
      "add": {
        "category": ["test2"]
      }
    }

    post micropub_url(subdomain: blog.subdomain), params: update_data, as: :json, headers: @headers

    get entry_url(last_entry)

    assert_select ".p-category", count: 2
    assert_select ".p-category", text: "test1", count: 1
    assert_select ".p-category", text: "test2", count: 1
  end

  test "402: Add a value to a non-existent property" do
    # Create entry
    blog = blogs(:valid)
    data = {
      "type": ["h-entry"],
      "properties": {
        "content": ["This test adds a category property to a post that previously had no category. After you run the update, this post should have the category test1."]
      }
    }

    post micropub_url(subdomain: blog.subdomain), params: data, as: :json, headers: @headers

    assert_response :created

    last_entry = Entry.last
    get entry_url(last_entry)

    assert_select ".p-category", false

    #Update entry:

    update_data = {
      "action": "update",
      "url": entry_url(last_entry),
      "add": {
        "category": ["test1"]
      }
    }

    post micropub_url(subdomain: blog.subdomain), params: update_data, as: :json, headers: @headers

    get entry_url(last_entry)

    assert_select ".p-category", count: 1
    assert_select ".p-category", text: "test1", count: 1
  end

  test "403: Remove a value from a property" do
    # Create entry
    blog = blogs(:valid)
    data = {
      "type": ["h-entry"],
      "properties": {
        "content": ["This test deletes a category from the post. After you run the update, this post should have only the category test1."],
        "category": ["test1", "test2"]
      }
    }

    post micropub_url(subdomain: blog.subdomain), params: data, as: :json, headers: @headers

    assert_response :created

    last_entry = Entry.last
    get entry_url(last_entry)

    assert_select ".p-category", count: 2
    assert_select ".p-category", text: "test1", count: 1
    assert_select ".p-category", text: "test2", count: 1

    #Update entry:

    update_data = {
      "action": "update",
      "url": entry_url(last_entry),
      "delete": {
        "category": ["test2"]
      }
    }

    post micropub_url(subdomain: blog.subdomain), params: update_data, as: :json, headers: @headers

    get entry_url(last_entry)

    assert_select ".p-category", count: 1
    assert_select ".p-category", text: "test1", count: 1
  end

  test "404: Remove a property" do
    # Create entry
    blog = blogs(:valid)
    data = {
      "type": ["h-entry"],
      "properties": {
        "content": ["This test deletes the category property from the post. After you run the update, this post should have no categories."],
        "category": ["test1", "test2"]
      }
    }

    post micropub_url(subdomain: blog.subdomain), params: data, as: :json, headers: @headers

    assert_response :created

    last_entry = Entry.last
    get entry_url(last_entry)

    assert_select ".p-category", count: 2
    assert_select ".p-category", text: "test1", count: 1
    assert_select ".p-category", text: "test2", count: 1

    #Update entry:

    update_data = {
      "action": "update",
      "url": entry_url(last_entry),
      "delete": ["category"]
    }

    post micropub_url(subdomain: blog.subdomain), params: update_data, as: :json, headers: @headers

    get entry_url(last_entry)

    assert_select ".p-category", count: 0
  end
end
