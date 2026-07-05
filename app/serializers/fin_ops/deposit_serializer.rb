module FinOps
  class DepositSerializer < ApplicationSerializer
    attributes :id, :public_id, :amount_cents, :created_at
  end
end
