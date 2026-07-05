module Accounting
  module JournalEntries
    class Create
      ENTRY_ATTRIBUTES = %i[
        reference_type reference_id description effective_at idempotency_key
      ]

      def initialize(read_balance: Accounts::ReadBalance.new)
        @_read_balance = read_balance
      end

      # @param entry_attributes [Hash]
      # @param postings [Array<Hash>]
      # @option entry_attributes [String] reference_type
      # @option entry_attributes [String] reference_id
      # @option entry_attributes [String] description
      # @option entry_attributes [DateTime] effective_at
      # @option entry_attributes [String] idempotency_key
      #
      # @return [void]
      # @raise [ActiveRecord::RecordNotFound]
      # @raise [Accounting::UnbalancedJournalEntryError]
      # @raise [Accounting::InsufficientBalanceError]
      #
      def call(postings:, **entry_attributes)
        raise UnbalancedJournalEntryError unless balanced?(postings)

        ApplicationRecord.transaction do
          entry = create_entry(entry_attributes)

          postings.each do |posting|
            account = Account.find_by!(label: posting[:account])
            # In a real app there would be safety measures against race conditions, but
            # I omit them for simplicity there
            #
            raise InsufficientBalanceError if !sufficient_balance?(account, posting)

            create_posting(account, entry, posting[:side], posting[:amount_cents])
          end
        end
      end

      private

      attr_reader :_read_balance

      def balanced?(postings)
        debits = postings.select { _1[:side] == :debit }.sum { _1[:amount_cents] }
        credits = postings.select { _1[:side] == :credit }.sum { _1[:amount_cents] }

        debits == credits
      end

      def create_entry(attributes)
        JournalEntry.create!(attributes.slice(*ENTRY_ATTRIBUTES))
      end

      def sufficient_balance?(account, posting)
        return true if account.natural_balance == posting[:side].to_s

        read_balance(account.label) >= posting[:amount_cents]
      end

      def create_posting(account, entry, side, amount_cents)
        entry.postings.create!(account:, side:, amount_cents:)
      end

      def read_balance(label)
        _read_balance.call(label:)
      end
    end
  end
end
