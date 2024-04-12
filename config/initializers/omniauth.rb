require_relative "../../lib/omniauth/strategies/cds"

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer if Rails.env.development? || Rails.env.test?
  provider :cds, Rails.application.credentials.dig(:cds, :client_id), Rails.application.credentials.dig(:cds, :client_secret)
end
