module FinOps
  class PayerAccount < ApplicationRecord
    has_many :deposits, foreign_key: :payer_id, dependent: :nullify
    has_many :withdrawals, foreign_key: :payer_id, dependent: :nullify
    has_many :outgoing_transfers, class_name: "FinOps::Transfer", foreign_key: :sender_id
    has_many :incoming_transfers, class_name: "FinOps::Transfer", foreign_key: :receiver_id
  end
end
