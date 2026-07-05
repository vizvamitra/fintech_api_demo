module FinOps
  class TransferSerializer < ApplicationSerializer
    attributes :id, :public_id, :amount_cents, :created_at
  end
end
