class CurrentClientSerializer < ApplicationSerializer
  attributes :public_id, :public_email, :created_at
  attribute(:balance_cents) { params[:balance_cents] }
end
