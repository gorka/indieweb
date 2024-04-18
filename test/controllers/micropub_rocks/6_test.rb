require "test_helper"

class MicropubRocks6Test < ActionDispatch::IntegrationTest
  setup do
    @headers = { "Authorization": "Bearer fake" }

    IndieAuth::TokenVerifier.stubs(:verify).returns([{}, nil])
  end

  test "600: Configuration Query" do
    get micropub_url(subdomain: blogs(:valid).subdomain, q: "config"), headers: @headers

    assert_response :ok
    response.parsed_body.assert_valid_keys("media-endpoint")
  end

  test "601: Syndication Endpoint Query" do
    get micropub_url(subdomain: blogs(:valid).subdomain, q: "syndicate-to"), headers: @headers

    assert_response :ok
    response.parsed_body.assert_valid_keys("syndicate-to")
  end

  test "602: Source Query (All Properties)" do
    # Create entry
    blog = blogs(:valid)
    data = {
      type: ["h-entry"],
      properties: {
        content: ["Test of querying the endpoint for the source content"],
        category: ["micropub", "test"]
      }
    }

    post micropub_url(subdomain: blog.subdomain), params: data, as: :json, headers: @headers

    assert_response :created

    # Query full entry
    get micropub_url(subdomain: blog.subdomain, q: "source", url: entry_url(Entry.last)), headers: @headers
    
    assert_response :ok
    assert_equal data.to_json, response.body
  end

  test "603: Source Query (Specific Properties)" do
    # Create entry
    blog = blogs(:valid)
    data = {
      type: ["h-entry"],
      properties: {
        content: ["Test of querying the endpoint for the source content"],
        category: ["micropub", "test"]
      }
    }

    post micropub_url(subdomain: blog.subdomain), params: data, as: :json, headers: @headers

    assert_response :created

    # Query entry properties
    get micropub_url(subdomain: blog.subdomain, q: "source", properties: ["content", "category"], url: entry_url(Entry.last)), headers: @headers

    assert_response :ok
    assert_equal data.to_json, response.body
  end

  test "603: Source Query (Specific Properties) (extra)" do
    # Create entry
    blog = blogs(:valid)
    data = {
      type: ["h-entry"],
      properties: {
        content: ["Test of querying the endpoint for the source content"],
        category: ["micropub", "test"]
      }
    }

    post micropub_url(subdomain: blog.subdomain), params: data, as: :json, headers: @headers

    assert_response :created

    # Query entry properties
    response_data = {
      type: ["h-entry"],
      properties: {
        content: ["Test of querying the endpoint for the source content"]
      }
    }

    get micropub_url(subdomain: blog.subdomain, q: "source", properties: ["content"], url: entry_url(Entry.last)), headers: @headers

    assert_response :ok
    assert_equal response_data.to_json, response.body
  end
end
