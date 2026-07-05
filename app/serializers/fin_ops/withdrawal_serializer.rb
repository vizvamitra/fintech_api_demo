module FinOps
  class WithdrawalSerializer < ApplicationSerializer
    attributes :id, :public_id, :amount_cents, :state, :created_at, :settled_at
  end
end
