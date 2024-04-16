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

     get entry_path(last_entry)

     assert_select ".h-entry", count: 1
     assert_select ".e-content", text: "This post will be deleted when the test succeeds."

     # Delete post:
     delete_data = {
       action: "delete",
       url: entry_path(last_entry)
     }

     post micropub_path, params: delete_data, headers: @headers

     assert_response :no_content

     # Verify post has been deleted:

     get entry_path(last_entry)

     assert_response :not_found
   end
 end
