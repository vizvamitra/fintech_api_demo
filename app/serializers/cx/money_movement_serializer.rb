module CX
  class MoneyMovementSerializer < ApplicationSerializer
    attributes :id, :kind, :amount_cents, :state, :reference, :initiated_at,
               :sender_id, :resolved_at, :error
  end
end
