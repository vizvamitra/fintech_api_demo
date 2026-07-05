module FinOps
  module Bookkeeping
    class RecordWithdrawal
      PP_BALANCE_ACCOUNT = "assets:cash:payment-processor-balance"
      REFERENCE_TYPE = "client_withdrawal"

      def initialize(accounting: Accounting::Interface.new)
        @_accounting = accounting
      end

      # @param payer [FinOps::PayerAccount]
      # @param withdrawal [FinOps::Withdrawal]
      #
      # @return [void]
      # @raise [Accounting::Error]
      #
      def call(payer:, withdrawal:)
        _accounting.create_journal_entry(
          reference_type: REFERENCE_TYPE,
          reference_id: withdrawal.public_id,
          description: entry_description(payer, withdrawal),
          effective_at: withdrawal.settled_at,
          idempotency_key: "withdrawal|#{withdrawal.public_id}|settlement",
          postings: [
            # Decrease assets
            posting(PP_BALANCE_ACCOUNT, :credit, withdrawal.amount_cents),
            # Decrease liabilities
            posting(payer.reserved_funds_account, :debit, withdrawal.amount_cents)
          ]
        )
      end

      private

      attr_reader :_accounting

      def entry_description(payer, withdrawal)
        [
          "Client Withdrawal #{withdrawal.public_id}",
          "Client #{payer.client_id}",
          "$#{(withdrawal.amount_cents.to_f / 100).round(2)}"
        ].join(" - ")
      end

      def posting(account, side, amount_cents)
        { account:, side:, amount_cents: }
      end
    end
  end
end
