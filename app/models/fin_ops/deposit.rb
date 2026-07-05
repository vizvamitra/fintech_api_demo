module FinOps
  class Deposit < ApplicationRecord
    belongs_to :payer, class_name: "FinOps::PayerAccount"

    validates :amount_cents, presence: true, numericality: { gte: 0 }
  end
end
