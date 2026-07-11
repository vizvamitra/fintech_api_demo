module FinOps
  module Bookkeeping
    class ProvisionCustomerAccounts
      LABEL_PATTERN = "liabilities:customer-deposits:%{customer_id}:%{subaccount}"
      GL_CODES = { available: "2110", reserved: "2120" }

      def initialize(accounting: Accounting::Interface.new)
        @_accounting = accounting
      end

      # @param customer_id [UUID]
      #
      # @return [Hash{available: String, reserved: String}]
      #
      def call(customer_id:)
        ApplicationRecord.transaction do
          available = create_customer_account(customer_id, :available)
          reserved = create_customer_account(customer_id, :reserved)

          { available: available.label, reserved: reserved.label }
        end
      end

      private

      attr_reader :_accounting

      def create_customer_account(customer_id, subaccount)
        _accounting.create_account(
          category: :liability,
          code: GL_CODES[subaccount],
          label: LABEL_PATTERN % { customer_id:, subaccount: },
          owner_ref: "customer:#{customer_id}"
        )
      end
    end
  end
end
