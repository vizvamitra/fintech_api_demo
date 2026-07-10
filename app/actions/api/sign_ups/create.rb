module Api
  module SignUps
    class Create
      def initialize(clients: ::CX::Interface.new)
        @_clients = clients
      end

      # @param email [String]
      #
      # @return [Credentials]
      # @raise [ActiveRecord::RecordInvalid]
      #
      def call(email:)
        ApplicationRecord.transaction do
          email = email.downcase

          client = _clients.create_client(public_email: email)
          Credentials.create!(email:, client_id: client.public_id)
        end
      rescue ::CX::EmailTakenError
        raise HttpErrors::UnprocessableContentError, :email_is_taken
      end

      private

      attr_reader :_clients
    end
  end
end
