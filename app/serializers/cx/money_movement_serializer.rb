module CX
  class MoneyMovementSerializer < ApplicationSerializer
    attributes :id, :kind, :amount_cents, :state, :reference, :initiated_at,
               :sender_email, :resolved_at, :error

    def sender_email(object)
      object.sender&.public_email
    end
  end
end
