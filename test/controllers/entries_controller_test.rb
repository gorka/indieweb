require "test_helper"

class EntriesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    entry = entries(:one)

    get entry_url(entry)

    assert_response :success
  end
end
