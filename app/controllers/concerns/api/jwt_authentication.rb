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
        jwt_public_key,
        true,
        algorithm: "RS256"
      ).first
    end

    def jwt_public_key
      OpenSSL::PKey.read(Rails.application.credentials.jwt_private_key!).public_key
    end
  end
end
