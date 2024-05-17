require "test_helper"

class BlogsControllerTest < ActionDispatch::IntegrationTest
  include OmniAuthHelper

  # guest (non signed in)

  test "guest cannot see blogs" do
    get blogs_url

    assert_response :redirect
    assert_redirected_to root_path
    assert_equal "You're not authorized to perform the requested action.", flash[:alert]
  end

  test "guest cannot see new blog form" do
    get new_blog_url

    assert_response :redirect
    assert_redirected_to root_path
    assert_equal "You're not authorized to perform the requested action.", flash[:alert]
  end

  test "guest cannot create blogs" do
    post blogs_url

    assert_response :redirect
    assert_redirected_to root_path
    assert_equal "You're not authorized to perform the requested action.", flash[:alert]
  end

  # user (signed in)

  test "user can see their blogs" do
    sign_in_with_provider("developer", 123456, users(:valid))

    get blogs_url

    assert_response :success
    assert_select "#blogs > p a", count: 3
  end

  test "user can see new blog form" do
    sign_in_with_provider("developer", 123456, users(:valid))

    get new_blog_url

    assert_response :success
  end

  test "user can create blog with valid params" do
    sign_in_with_provider("developer", 123456, users(:valid))

    post blogs_url, params: { blog: { title: "Test blog", subdomain: "test" } }

    assert_response :redirect
    assert_redirected_to Blog.last
  end

  test "user cannot create blog with invalid params" do
    sign_in_with_provider("developer", 123456, users(:valid))

    post blogs_url, params: { blog: { title: "", subdomain: "test" } }

    assert_response :unprocessable_entity
  end

  test "user cannot see another user's blog" do
    sign_in_with_provider("developer", 123456, users(:valid))
  
    get blog_url(blogs(:two))
  
    assert_response :redirect
    assert_redirected_to root_path
    assert_equal "You're not authorized to perform the requested action.", flash[:alert]
  end

  test "user cannot see another user's edit blog form" do
    sign_in_with_provider("developer", 123456, users(:valid))
  
    get edit_blog_url(blogs(:two))
  
    assert_response :redirect
    assert_redirected_to root_path
    assert_equal "You're not authorized to perform the requested action.", flash[:alert]
  end

  test "user cannot update another user's blog" do
    sign_in_with_provider("developer", 123456, users(:valid))
  
    patch blog_url(blogs(:two)), params: { blog: {} }
  
    assert_response :redirect
    assert_redirected_to root_path
    assert_equal "You're not authorized to perform the requested action.", flash[:alert]
  end

  test "user cannot destroy another user's blog" do
    sign_in_with_provider("developer", 123456, users(:valid))
  
    delete blog_url(blogs(:two))
  
    assert_response :redirect
    assert_redirected_to root_path
    assert_equal "You're not authorized to perform the requested action.", flash[:alert]
  end

  # owner

  test "owner can see their own blog" do
    sign_in_with_provider("developer", 987654, users(:two))
  
    get blog_url(blogs(:two))
  
    assert_response :success
  end

  test "owner can see their own blog's edit form" do
    sign_in_with_provider("developer", 987654, users(:two))
  
    get edit_blog_url(blogs(:two))

    assert_response :success
  end

  test "owner can update their own blog" do
    sign_in_with_provider("developer", 987654, users(:two))
  
    patch blog_url(blogs(:two)), params: { blog: { title: "Updated title" } }
  
    assert_response :redirect
    assert_redirected_to blog_url(blogs(:two))
    assert_equal "Blog was successfully updated.", flash[:notice]
  end

  test "owner can destroy their own blog" do
    sign_in_with_provider("developer", 987654, users(:two))
  
    delete blog_url(blogs(:two))
  
    assert_response :redirect
    assert_redirected_to blogs_url
    assert_equal "Blog was successfully destroyed.", flash[:notice]
  end
end
