module Accounting
  class Posting < ApplicationRecord
    belongs_to :account, inverse_of: :postings
    belongs_to :journal_entry, inverse_of: :postings

    enum :side, { debit: 1, credit: -1 }

    validates :amount_cents, :side, presence: true
    validates :amount_cents, numericality: { greater_than: 0 }
  end
end
