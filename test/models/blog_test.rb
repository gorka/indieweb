require "test_helper"

class BlogTest < ActiveSupport::TestCase
  def setup
    @blog = blogs(:valid)
  end

  test "valid blog" do
    assert @blog.valid?
  end

  test "invalid without title" do
    @blog.title = nil

    assert_not @blog.valid?
    assert_not_nil @blog.errors[:title]
  end

  test "invalid without subdomain" do
    @blog.subdomain = nil

    assert_not @blog.valid?
    assert_not_nil @blog.errors[:subdomain]
  end

  test "invalid with subdomain shorter than 3 chars" do
    @blog.subdomain = "aa"

    assert_not @blog.valid?
    assert_not_nil @blog.errors[:subdomain]
  end

  test "invalid with subdomain longer than 20 chars" do
    @blog.subdomain = "aaaaaaaaaaaaaaaaaaaaaaaaa"

    assert_not @blog.valid?
    assert_not_nil @blog.errors[:subdomain]
  end


  test "invalid with subdomain with invalid characters" do
    @blog.subdomain = "inv4l1d_SuB"

    assert_not @blog.valid?
    assert_not_nil @blog.errors[:subdomain]
  end
end
