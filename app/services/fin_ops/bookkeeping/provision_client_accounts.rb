module FinOps
  module Bookkeeping
    class ProvisionClientAccounts
      LABEL_PATTERN = "liabilities:client-deposits:%{client_id}:%{subaccount}"
      GL_CODES = { available: "2110", reserved: "2120" }

      def initialize(accounting: Accounting::Interface.new)
        @_accounting = accounting
      end

      # @param client_id [UUID]
      #
      # @return [Hash{available: String, reserved: String}]
      #
      def call(client_id:)
        ApplicationRecord.transaction do
          available = create_client_account(client_id, :available)
          reserved = create_client_account(client_id, :reserved)

          { available: available.label, reserved: reserved.label }
        end
      end

      private

      attr_reader :_accounting

      def create_client_account(client_id, subaccount)
        _accounting.create_account(
          category: :liability,
          code: GL_CODES[subaccount],
          label: LABEL_PATTERN % { client_id:, subaccount: },
          owner_ref: "client:#{client_id}"
        )
      end
    end
  end
end
