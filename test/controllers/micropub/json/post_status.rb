require "test_helper"

class MicropubJsonPostStatusTest < ActionDispatch::IntegrationTest
  include OmniAuthHelper

  test "a guest should not see a draft post" do
    get entry_url(subdomain: blogs(:valid).subdomain, id: entries(:draft))

    assert_response :not_found
  end

  test "a user should not see a draft post from another user" do
    sign_in_with_provider("two", 654321, users(:two))

    get entry_url(subdomain: blogs(:valid).subdomain, id: entries(:draft))

    assert_response :not_found
  end

  test "the owner should see their draft post" do
    sign_in_with_provider("developer", 123456, users(:valid))

    get entry_url(subdomain: blogs(:valid).subdomain, id: entries(:draft))

    assert_response :ok
  end

  # todo:
    # guest:
      # posts list don't list that post
    # user:
      # posts list don't list that post
    # owner:
      # posts list list that post
      # post page 200
end