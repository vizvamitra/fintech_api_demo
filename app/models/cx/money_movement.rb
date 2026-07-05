module CX
  class MoneyMovement < ApplicationRecord
    belongs_to :client

    enum :kind, { deposit: 1, withdrawal: 2, outgoing_transfer: 3, incoming_transfer: 4 }
    enum :state, { pending: 1, settled: 2, failed: 3 }

    validates :kind, :state, :amount_cents, :initiated_at, presence: true
  end
end
