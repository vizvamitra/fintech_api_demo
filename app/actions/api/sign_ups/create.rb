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
          credentials = Credentials.create(email:)

          client = _clients.create_client(contact_email: email)

          credentials.update!(client_id: client.public_id)
        end
      end

      private

      attr_reader :_clients
    end
  end
end
