require "test_helper"

class MicropubRocks5Test < ActionDispatch::IntegrationTest
  setup do
    # todo: mock to avoid http requests during tests.
    @headers = {
      "Authorization": "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJtZSI6Imh0dHBzOlwvXC9maW5jaC1wb3B1bGFyLWltcGFsYS5uZ3Jvay1mcmVlLmFwcFwvIiwiaXNzdWVkX2J5IjoiaHR0cHM6XC9cL3Rva2Vucy5pbmRpZWF1dGguY29tXC90b2tlbiIsImNsaWVudF9pZCI6Imh0dHBzOlwvXC9taWNyb3B1Yi5yb2Nrc1wvIiwiaXNzdWVkX2F0IjoxNjkzODU3ODk3LCJzY29wZSI6ImNyZWF0ZSB1cGRhdGUgZGVsZXRlIHVuZGVsZXRlIiwibm9uY2UiOjg4Njc4OTY5fQ.BPoiJoCYxobqK8QJHc3MeolyStkEZl5pQIw2pD9isNg"
    }
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

    get entry_path(last_entry)

    assert_select ".h-entry", count: 1
    assert_select ".e-content", text: "This post will be deleted when the test succeeds."

    # Delete post:
    delete_data = {
      "action": "delete",
      "url": entry_path(last_entry)
    }

    post micropub_path, params: delete_data, as: :json, headers: @headers

    assert_response :no_content

    # Verify post has been deleted:
    get entry_path(last_entry)

    assert_response :not_found
  end
end
