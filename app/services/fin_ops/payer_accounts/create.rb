module FinOps
  module PayerAccounts
    class Create
      def initialize(provision_customer_accounts: Bookkeeping::ProvisionCustomerAccounts.new)
        @_provision_customer_accounts = provision_customer_accounts
      end

      # @param customer_id [UUID]
      #
      # @return [FinOps::PayerAccount]
      #
      def call(customer_id:)
        ApplicationRecord.transaction do
          accounts = provision_customer_accounts(customer_id)

          PayerAccount.create!(
            customer_id:,
            available_funds_account: accounts[:available],
            reserved_funds_account: accounts[:reserved]
          )
        end
      end

      private

      attr_reader :_provision_customer_accounts

      def provision_customer_accounts(customer_id)
        _provision_customer_accounts.call(customer_id:)
      end
    end
  end
end
