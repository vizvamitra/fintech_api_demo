module Api
  module SignIns
    class Create
      ISSUER = "whatever"
      AUDIENCE = "whatever"
      EXPIRY_INTERVAL = 1.day

      def initialize(jwt_private_key: Rails.application.credentials.jwt_private_key!)
        @_jwt_private_key = OpenSSL::PKey.read(jwt_private_key)
      end

      # @param email [String]
      #
      # @return [String] JWT token
      # @raise [ActiveRecord::RecordNotFound]
      #
      def call(email:)
        credentials = Credentials.find_by!(email: email.downcase)
        issue_jwt(credentials)
      end

      private

      attr_reader :_jwt_private_key

      def issue_jwt(credentials)
        payload = {
          iss: ISSUER,
          sub: credentials.id.to_s,
          aud: AUDIENCE,
          exp: EXPIRY_INTERVAL.from_now.to_i
        }

        JWT.encode(payload, _jwt_private_key, "RS256")
      end
    end
  end
end
