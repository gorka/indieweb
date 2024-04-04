require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:valid)
  end

  test "valid user" do
    assert @user.valid?
  end

  test "invalid without name" do
    @user.name = nil

    assert_not @user.valid?
    assert_not_nil @user.errors[:name]
  end

  test "invalid without email" do
    @user.email = nil

    assert_not @user.valid?
    assert_not_nil @user.errors[:email]
  end

  test "omniauth_providers" do
    assert_equal 1, @user.omniauth_providers.size
  end
end
