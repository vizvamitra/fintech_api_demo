module Accounting
  module Accounts
    class ReadBalance
      # @param label [String]
      #
      # @return [Integer]
      # @raise [ActiveRecord::RecordNotFound]
      #
      def call(label:)
        account = Account.find_by!(label:)

        # In a real system there would be some optimisations in place to avoid summing up
        # all the ledger postings, but in this demo system I skip that for simplicity
        #
        account.postings.sum("side * amount_cents").to_i * account.balance_multiplier
      end
    end
  end
end
