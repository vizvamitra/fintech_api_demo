module Accounting
  module Accounts
    class Create
      NATURAL_BALANCES = {
        asset: :debit,
        liability: :credit
      }

      # @param category [Symbol]
      # @param code [String]
      # @param label [String]
      # @param owner_ref [String, nil]
      #
      # @return [Accounting::Account]
      # @raise [ActiveRecord::RecordNotUnique]
      #
      def call(category:, code:, label:, owner_ref: nil)
        Account.create!(
          category:,
          code:,
          natural_balance: NATURAL_BALANCES[category],
          label:,
          owner_ref:
        )
      end
    end
  end
end
