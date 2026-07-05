module CX
  module Clients
    class Create
      def initialize(fin_ops: FinOps::Interface.new)
        @_fin_ops = fin_ops
      end

      # @param contact_email [String]
      #
      # @return [CX::Client]
      #
      def call(contact_email:)
        ApplicationRecord.transaction do
          client = Client.create!(contact_email:)
          _fin_ops.create_payer_account(client_id: client.public_id)

          client
        end
      end

      private

      attr_reader :_fin_ops
    end
  end
end
