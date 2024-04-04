require "test_helper"

class OmniauthProviderTest < ActiveSupport::TestCase
  def setup
    @omniauth_provider = omniauth_providers(:valid)
  end

  test "valid omniauth_provider" do
    assert @omniauth_provider.valid?
  end

  test "invalid without user" do
    @omniauth_provider.user = nil

    assert_not @omniauth_provider.valid?
    assert_not_nil @omniauth_provider.errors[:user]
  end

  test "invalid without provider" do
    @omniauth_provider.provider = nil

    assert_not @omniauth_provider.valid?
    assert_not_nil @omniauth_provider.errors[:provider]
  end

  test "invalid without uid" do
    @omniauth_provider.uid = nil

    assert_not @omniauth_provider.valid?
    assert_not_nil @omniauth_provider.errors[:uid]
  end
end
