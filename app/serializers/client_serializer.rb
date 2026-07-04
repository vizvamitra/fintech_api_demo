class ClientSerializer < ApplicationSerializer
  attributes :public_id, :contact_email, :created_at, :updated_at
  attribute(:deposit) { params[:deposit] }
end
