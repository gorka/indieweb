require "test_helper"

class MicropubRocks7Test < ActionDispatch::IntegrationTest
  setup do
    @headers = { "Authorization": "Bearer fake" }

    IndieAuth::TokenVerifier.stubs(:verify).returns([{}, nil])
  end

  test "700: Upload a jpg to the Media Endpoint" do
    blog = blogs(:valid)
    data = {
      file: fixture_file_upload("sunset.jpg", "image/jpeg")
    }

    post media_url(subdomain: blog.subdomain), params: data, headers: @headers

    assert_response :created
    assert_equal url_for(PhotoWithAlt.last.photo), response.headers["Location"]
  end

  test "701: Upload a png to the Media Endpoint" do
    blog = blogs(:valid)
    data = {
      file: fixture_file_upload("micropub-rocks.png", "image/png")
    }

    post media_url(subdomain: blog.subdomain), params: data, headers: @headers

    assert_response :created
    assert_equal url_for(PhotoWithAlt.last.photo), response.headers["Location"]
  end

  test "702: Upload a gif to the Media Endpoint" do
    blog = blogs(:valid)
    data = {
      file: fixture_file_upload("power-rangers.gif", "image/gif")
    }

    post media_url(subdomain: blog.subdomain), params: data, headers: @headers

    assert_response :created
    assert_equal url_for(PhotoWithAlt.last.photo), response.headers["Location"]
  end

  test "Do not upload invalid type content to the Media Endpoint" do
    blog = blogs(:valid)
    data = {
      file: fixture_file_upload("a-pdf-file.pdf", "application/pdf")
    }

    post media_url(subdomain: blog.subdomain), params: data, headers: @headers

    assert_response :unprocessable_entity
  end
end
