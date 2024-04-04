require "test_helper"

class Users::SessionsControllerTest < ActionDispatch::IntegrationTest
  include OmniAuthHelper

  setup do
    @user = users(:valid)
  end

  test "create new session for existing user" do
    omniauth_setup_for_user(:developer, 123456, @user)

    assert_no_difference "User.count" do
      get auth_callback_url("developer")
    end

    assert_equal @user.id, session[:user_id]

    assert_redirected_to root_path
  end

  test "create user with valid data" do
    user = User.new name: "Miguel Bosé", email: "miguel.bose@email.com"

    omniauth_setup_for_user(:developer, 234567, user)

    assert_difference "User.count", 1 do
      get auth_callback_url("developer")
    end

    assert_equal User.last.id, session[:user_id]

    assert_redirected_to root_path
  end

  test "don't create user if invalid provider" do
    user = User.new name: "Miguel Bosé", email: "miguel.bose@email.com"

    omniauth_setup_for_user(:fake, 234567, user)

    assert_no_difference "User.count" do
      get auth_callback_url("fake")
    end

    assert_equal "Something went wrong.", flash[:alert]

    assert_redirected_to root_path
  end

  test "don't create user if provider and uid is assigned to another user" do
    user = User.new name: "Miguel Bosé", email: "miguel.bose@email.com"

    omniauth_setup_for_user(:developer, 123456, user)

    assert_no_difference "User.count" do
      get auth_callback_url("developer")
    end

    assert_equal @user.id, session[:user_id]

    assert_redirected_to root_path
  end

  test "don't create user with invalid data" do
    user = User.new name: "Miguel Bosé"

    omniauth_setup_for_user(:developer, 234567, user)

    assert_no_difference "User.count" do
      get auth_callback_url("developer")
    end

    assert_equal "Something went wrong.", flash[:alert]

    assert_redirected_to root_path
  end
end
