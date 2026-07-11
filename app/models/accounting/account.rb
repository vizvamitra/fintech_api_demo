module Accounting
  class Account < ApplicationRecord
    # Fullscale accounting system would also have equity, revenue, expense and temporary
    enum :category, { asset: 1, liability: 2 }
    enum :natural_balance, { debit: 1, credit: -1 }, suffix: "balance"
    enum :code, {
      payment_processor_balance: "1110",
      customer_deposit_available: "2110",
      customer_deposit_reserved: "2120"
    }

    has_many :postings
    has_many :journal_entries, through: :postings

    validates :code, :label, :category, :natural_balance, presence: true

    def balance_multiplier
      natural_balance_before_type_cast
    end
  end
end
