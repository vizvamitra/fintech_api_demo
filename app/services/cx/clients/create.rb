module CX
  module Clients
    class Create
      def initialize(fin_ops: FinOps::Interface.new)
        @_fin_ops = fin_ops
      end

      # @param public_email [String]
      #
      # @return [CX::Client]
      #
      def call(public_email:)
        ApplicationRecord.transaction do
          client = Client.create!(public_email:)
          _fin_ops.create_payer_account(client_id: client.public_id)

          client
        end
      end

      private

      attr_reader :_fin_ops
    end
  end
end
