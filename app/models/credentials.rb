class Credentials < ApplicationRecord
  belongs_to :customer, class_name: "CX::Customer", primary_key: :public_id

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
end
