require "test_helper"

class MicropubTest < ActiveSupport::TestCase
  test "returns an entry from a url with valid subdomain" do
    entry = entries(:note)
    url = "https://#{entry.blog.subdomain}.indieblog.xyz/entries/#{entry.id}"

    assert_equal Micropub.resource_from_url(url), entry
  end

  test "returns an array from a url with custom domain" do
    entry = entries(:custom_domain)
    url = "https://#{entry.blog.custom_domain}/entries/#{entry.id}"

    assert_equal Micropub.resource_from_url(url), entry
  end
end
