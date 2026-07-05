module FinOps
  class Deposit < ApplicationRecord
    belongs_to :payer, class_name: "FinOps::PayerAccount"

    validates :amount_cents, presence: true, numericality: { greater_than: 0 }
  end
end
