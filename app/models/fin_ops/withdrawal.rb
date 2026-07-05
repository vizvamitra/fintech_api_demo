module FinOps
  class Withdrawal < ApplicationRecord
    belongs_to :payer, class_name: "FinOps::PayerAccount"

    enum :state, { initiated: 1, settled: 2, failed: 3 }

    validates :amount_cents, presence: true, numericality: { greater_than: 0 }
  end
end
