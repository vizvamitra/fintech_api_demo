FactoryBot.define do
  factory :fin_ops_payer_account, class: 'FinOps::PayerAccount' do
    client_id { SecureRandom.uuid }
    sequence(:available_funds_account) do
      "liabilities:client-deposits:#{client_id}:available"
    end
    sequence(:reserved_funds_account) do
      "liabilities:client-deposits:#{client_id}:reserved"
    end
  end
end
