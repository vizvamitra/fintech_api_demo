class ClientSerializer < ApplicationSerializer
  attributes :public_id, :contact_email, :created_at, :updated_at
  attribute(:balance_cents) { params[:balance_cents] }
end
