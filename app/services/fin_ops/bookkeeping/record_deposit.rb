module FinOps
  module Bookkeeping
    class RecordDeposit
      PP_BALANCE_ACCOUNT = "assets:payment-processor-balance"
      REFERENCE_TYPE = "client_deposit"

      def initialize(accounting: Accounting::Interface.new)
        @_accounting = accounting
      end

      # @param payer [FinOps::PayerAccount]
      # @param deposit [FinOps::Deposit]
      #
      # @return [void]
      # @raise [Accounting::Error]
      #
      def call(payer:, deposit:)
        _accounting.create_journal_entry(
          reference_type: REFERENCE_TYPE,
          reference_id: deposit.public_id,
          description: entry_description(payer, deposit),
          effective_at: deposit.created_at,
          postings: [
            # Increase assets
            posting(PP_BALANCE_ACCOUNT, :debit, deposit.amount_cents),
            # Increase liabilities
            posting(payer.available_funds_account, :credit, deposit.amount_cents)
          ]
        )
      end

      private

      attr_reader :_accounting

      def entry_description(payer, deposit)
        [
          "Client Deposit #{deposit.public_id}",
          "Client #{payer.client_id}",
          "$#{(deposit.amount_cents.to_f / 100).round(2)}"
        ].join(" - ")
      end

      def posting(account, side, amount_cents)
        { account:, side:, amount_cents: }
      end
    end
  end
end
