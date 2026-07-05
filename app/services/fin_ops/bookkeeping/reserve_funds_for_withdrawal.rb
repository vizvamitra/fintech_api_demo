module FinOps
  module Bookkeeping
    class ReserveFundsForWithdrawal
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
          effective_at: withdrawal.created_at,
          idempotency_key: "withrawal|#{withdrawal.public_id}|reservation",
          postings: [
            # transfer from available to reserved account
            posting(payer.available_funds_account, :debit, withdrawal.amount_cents),
            posting(payer.reserved_funds_account, :credit, withdrawal.amount_cents)
          ]
        )
      end

      private

      attr_reader :_accounting

      def entry_description(payer, withdrawal)
        [
          "Client Withdrawal #{withdrawal.public_id}",
          "Client #{payer.client_id}",
          "$#{(withdrawal.amount_cents.to_f / 100).round(2)}",
          "Fund Reservation"
        ].join(" - ")
      end

      def posting(account, side, amount_cents)
        { account:, side:, amount_cents: }
      end
    end
  end
end
