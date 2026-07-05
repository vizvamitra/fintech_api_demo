module FinOps
  module Bookkeeping
    class RecordTransfer
      REFERENCE_TYPE = "transfer"

      def initialize(accounting: Accounting::Interface.new)
        @_accounting = accounting
      end

      # @param sender [FinOps::PayerAccount]
      # @param receiver [FinOps::PayerAccount]
      # @param transfer [FinOps::Transfer]
      #
      # @return [void]
      # @raise [Accounting::Error]
      #
      def call(sender:, receiver:, transfer:)
        _accounting.create_journal_entry(
          reference_type: REFERENCE_TYPE,
          reference_id: transfer.public_id,
          description: entry_description(sender, receiver, transfer),
          effective_at: transfer.created_at,
          idempotency_key: "transfer|#{transfer.public_id}",
          postings: [
            # Decrease assets
            posting(sender.available_funds_account, :debit, transfer.amount_cents),
            # Decrease liabilities
            posting(receiver.available_funds_account, :credit, transfer.amount_cents)
          ]
        )
      end

      private

      attr_reader :_accounting

      def entry_description(sender, receiver, transfer)
        [
          "Inter-Client Transfer #{transfer.public_id}",
          "Sender #{sender.client_id}",
          "Receiver #{receiver.client_id}",
          "$#{(transfer.amount_cents.to_f / 100).round(2)}"
        ].join(" - ")
      end

      def posting(account, side, amount_cents)
        { account:, side:, amount_cents: }
      end
    end
  end
end
