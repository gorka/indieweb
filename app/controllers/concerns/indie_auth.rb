module IndieAuth
  extend ActiveSupport::Concern

  included do
    before_action :authenticate
  end

  private

  def authenticate
    # https://tokens.indieauth.com/#verify

    token = http_header_token || post_body_token

    render json: {
      "error": "unauthorized",
      "error_description": "You must provide an auth token"
    }, status: :unauthorized and return if !token

    # todo: Quill sends auth token both ways and I want to use Quill.
    # render json: {
    #   "error": "bad request",
    #   "error_description": "Provide only one auth token"
    # }, status: :bad_request and return if http_header_token && post_body_token

    data, error = IndieAuth::TokenVerifier.verify(token)

    render json: error[:body], status: error[:status] and return if error

    data

    # todo:
    # - verify that me is the same blog domain
    # - verify that issued_by is the same blog token_endpoint
    # - verify scope permission
    # - store? client_id for reference
  end

  def http_header_token
    authenticate_with_http_token { |token, _options| token }
  end

  def post_body_token
    params[:access_token]
  end
end
