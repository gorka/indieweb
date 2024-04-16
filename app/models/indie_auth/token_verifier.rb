module IndieAuth
  class TokenVerifier
    # todo: use blog's token_endpoint
    TOKEN_ENDPOINT = "https://tokens.indieauth.com/token"

    def self.verify(token)
      response = Faraday.get(TOKEN_ENDPOINT, {}, {
        "Accept": "application/json",
        "Authorization": "Bearer #{token}"
      })

      handle_response(response)
    rescue Faraday::Error => error
      handle_error(error.response[:status], error.response[:body])
    end

    private

      def self.handle_error(status, body)
        [nil, {
          status: status,
          body: JSON.parse(body).with_indifferent_access
        }]
      end

      def self.handle_response(response)
        if response.success?
          [JSON.parse(response.body).with_indifferent_access, nil]
        else
          handle_error(response.status, response.body)
        end
      end
  end
end
