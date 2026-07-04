module Api
  module SignIns
    class Create
      ISSUER = "whatever"
      AUDIENCE = "whatever"
      EXPIRY_INTERVAL = 1.day

      def initialize(jwt_secret_key: Rails.application.credentials.jwt_secret_key!)
        @_jwt_secret_key = jwt_secret_key
      end

      # @param email [String]
      #
      # @return [String] JWT token
      # @raise [ActiveRecord::RecordNotFound]
      #
      def call(email:)
        credentials = Credentials.find_by!(email:)
        issue_jwt(credentials)
      end

      private

      attr_reader :_jwt_secret_key

      def issue_jwt(credentials)
        payload = {
          iss: ISSUER,
          sub: credentials.id.to_s,
          aud: AUDIENCE,
          exp: EXPIRY_INTERVAL.from_now.to_i
        }

        JWT.encode(payload, _jwt_secret_key, "HS256")
      end
    end
  end
end
