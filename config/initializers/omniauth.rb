module OmniAuth
  module Strategies
    class Cds < OmniAuth::Strategies::OAuth2
      option :name, "cds"

      option :client_options, {
        site: "https://cajondesaastre.com",
        authorize_path: "/oauth/authorize"
      }

      uid do
        raw_info["id"]
      end

      info do
        {
          name: raw_info["name"],
          email: raw_info["email"],
        }
      end

      extra do
        {
          raw_info: raw_info
        }
      end

      def raw_info
        @raw_info ||= access_token.get("/api/v1/me").parsed
      end
    end
  end
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer if Rails.env.development? || Rails.env.test?
  provider :cds, Rails.application.credentials.dig(:cds, :client_id), Rails.application.credentials.dig(:cds, :client_secret)
end
