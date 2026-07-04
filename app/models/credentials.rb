class Credentials < ApplicationRecord
  belongs_to :client, class_name: "CX::Client", primary_key: :public_id

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
end
