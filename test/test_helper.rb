ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "mocha/minitest"
require "webmock/minitest"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

module OmniAuthHelper
  def omniauth_setup_for_user(provider, uid, user)
    OmniAuth.config.test_mode = true

    OmniAuth.config.add_mock(
      provider,
      uid:,
      info: {
        name: user.name,
        email: user.email
      }
    )
  end

  def sign_in_with_provider(provider, uid, user)
    omniauth_setup_for_user(provider, uid, user)
    get auth_callback_url(provider)
  end
end
