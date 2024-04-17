require "test_helper"

class MicropubRocks6Test < ActionDispatch::IntegrationTest
  setup do
    @headers = { "Authorization": "Bearer fake" }

    IndieAuth::TokenVerifier.stubs(:verify).returns([{}, nil])
  end

  test "600: Configuration Query" do
    get micropub_url(subdomain: blogs(:valid).subdomain, q: "config")

    assert_response :ok
  end
end
