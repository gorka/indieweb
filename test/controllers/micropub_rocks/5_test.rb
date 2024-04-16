require "test_helper"

 class MicropubRocks5Test < ActionDispatch::IntegrationTest
  setup do
    @headers = { "Authorization": "Bearer fake" }

    IndieAuth::TokenVerifier.stubs(:verify).returns([{}, nil])
  end

   test "500: Delete a post (form-encoded)" do
     # Create post:
     create_data = {
       h: "entry",
       content: "This post will be deleted when the test succeeds."
     }

     post micropub_path, params: create_data, headers: @headers

     assert_response :created

     # Verify post exists:

     last_entry = Entry.last

     get entry_url(last_entry)

     assert_select ".h-entry", count: 1
     assert_select ".e-content", text: "This post will be deleted when the test succeeds."

     # Delete post:
     delete_data = {
       action: "delete",
       url: entry_url(last_entry)
     }

     post micropub_path, params: delete_data, headers: @headers

     assert_response :no_content

     # Verify post has been deleted:

     get entry_url(last_entry)

     assert_response :not_found
   end

  test "501: Delete a post (JSON)" do
    # Create post:
    data = {
      "type": ["h-entry"],
      "properties": {
        "content": ["This post will be deleted when the test succeeds."]
      }
    }

    post micropub_path, params: data, as: :json, headers: @headers

    assert_response :created

    # Verify post exists:
    last_entry = Entry.last

    get entry_url(last_entry)

    assert_select ".h-entry", count: 1
    assert_select ".e-content", text: "This post will be deleted when the test succeeds."

    # Delete post:
    delete_data = {
      "action": "delete",
      "url": entry_url(last_entry)
    }

    post micropub_path, params: delete_data, as: :json, headers: @headers

    assert_response :no_content

    # Verify post has been deleted:
    get entry_url(last_entry)

    assert_response :not_found
  end

  test "502: Undelete a post (form-encoded)" do
    # Create post:
    create_data = {
      h: "entry",
      content: "This post will be deleted, and should be restored after undeleting it."
    }

    post micropub_path, params: create_data, headers: @headers

    assert_response :created

    # Verify post exists:
    last_entry = Entry.last

    get entry_url(last_entry)

    assert_select ".h-entry", count: 1
    assert_select ".e-content", text: "This post will be deleted, and should be restored after undeleting it."

    # Delete post:
    delete_data = {
      action: "delete",
      url: entry_url(last_entry)
    }

    post micropub_path, params: delete_data, headers: @headers

    assert_response :no_content

    # Verify post has been deleted:
    get entry_url(last_entry)

    assert_response :not_found

    # Undelete post:
    undelete_data = {
      action: "undelete",
      url: entry_url(last_entry)
    }

    post micropub_path, params: undelete_data, headers: @headers

    # Verify post has been undeleted:
    get entry_url(last_entry)

    assert_select ".h-entry", count: 1
    assert_select ".e-content", text: "This post will be deleted, and should be restored after undeleting it."
  end


  test "503: Undelete a post (JSON)" do
    # Create post:
    data = {
      "type": ["h-entry"],
      "properties": {
        "content": ["This post will be deleted, and should be restored after undeleting it."]
      }
    }

    post micropub_path, params: data, as: :json, headers: @headers

    assert_response :created

    # Verify post exists:
    last_entry = Entry.last

    get entry_url(last_entry)

    assert_select ".h-entry", count: 1
    assert_select ".e-content", text: "This post will be deleted, and should be restored after undeleting it."

    # Delete post:
    delete_data = {
      "action": "delete",
      "url": entry_url(last_entry)
    }

    post micropub_path, params: delete_data, as: :json, headers: @headers

    assert_response :no_content

    # Verify post has been deleted:
    get entry_url(last_entry)

    assert_response :not_found

    # Undelete post:
    undelete_data = {
      action: "undelete",
      url: entry_url(last_entry)
    }

    post micropub_path, params: undelete_data, as: :json, headers: @headers

    # Verify post has been undeleted:
    get entry_url(last_entry)

    assert_select ".h-entry", count: 1
    assert_select ".e-content", text: "This post will be deleted, and should be restored after undeleting it."
  end
end
