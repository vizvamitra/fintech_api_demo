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
      jwt = (request.headers["Authorization"] || "").match(/^Bearer (?<token>.+)$/)[:token]
      payload = JWT.decode(jwt, Rails.application.credentials.jwt_secret_key!, true, algorithm: "HS256").first

      credentials = Credentials.find(payload["sub"].to_i)
      raise HttpErrors::Unauthenticated unless credentials

      @current_credentials = credentials
    rescue JWT::VerificationError
      raise HttpErrors::Unauthenticated
    end
  end
end
