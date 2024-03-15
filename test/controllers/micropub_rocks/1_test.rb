require "test_helper"

class MicropubRocks1Test < ActionDispatch::IntegrationTest
  test "100: Create an h-entry post (form-encoded)" do
    data = {
      h: "entry",
      content: "Micropub test of creating a basic h-entry"
    }

    post micropub_path, params: data

    assert_response :created
  end
end
