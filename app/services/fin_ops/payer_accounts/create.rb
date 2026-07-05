module FinOps
  module PayerAccounts
    class Create
      def initialize(provision_client_accounts: Bookkeeping::ProvisionClientAccounts.new)
        @_provision_client_accounts = provision_client_accounts
      end

      # @param client_id [UUID]
      #
      # @return [FinOps::PayerAccount]
      #
      def call(client_id:)
        ApplicationRecord.transaction do
          accounts = provision_client_accounts(client_id)

          PayerAccount.create!(
            client_id:,
            available_funds_account: accounts[:available],
            reserved_funds_account: accounts[:reserved]
          )
        end
      end

      private

      attr_reader :_provision_client_accounts

      def provision_client_accounts(client_id)
        _provision_client_accounts.call(client_id:)
      end
    end
  end
end
