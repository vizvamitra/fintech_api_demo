module FinOps
  class Transfer < ApplicationRecord
    belongs_to :sender, class_name: "FinOps::PayerAccount"
    belongs_to :receiver, class_name: "FinOps::PayerAccount"

    validates :amount_cents, presence: true, numericality: { gte: 0 }
  end
end
