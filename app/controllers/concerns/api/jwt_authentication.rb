module Api
  module JwtAuthentication
    extend ActiveSupport::Concern

    included do
      before_action :authenticate!
    end

    private

    attr_reader :current_credentials

    # I intentionally left JWT authn rudimentary. This setup obviously is not secure
    # and can't be used in a real production app
    #
    def authenticate!
      header = request.headers["Authorization"] || ""
      jwt = header.scan(/^(?>Bearer )(?<token>.+)$/).flatten.first&.squish
      payload = decode_jwt(jwt)

      credentials = Credentials.find(payload["sub"].to_i)
      raise HttpErrors::UnauthorizedError unless credentials

      @current_credentials = credentials
    rescue JWT::VerificationError, JWT::DecodeError
      raise HttpErrors::UnauthorizedError
    end

    def decode_jwt(jwt)
      JWT.decode(
        jwt,
        Rails.application.credentials.jwt_secret_key!,
        true,
        algorithm: "HS256"
      ).first
    end
  end
end
