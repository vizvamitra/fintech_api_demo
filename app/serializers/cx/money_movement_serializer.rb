module CX
  class MoneyMovementSerializer < ApplicationSerializer
    attributes :id, :kind, :amount_cents, :state, :sender_id, :initiated_at,
               :resolved_at, :error
  end
end
