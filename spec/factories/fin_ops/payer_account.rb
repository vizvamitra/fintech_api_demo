FactoryBot.define do
  factory :fin_ops_payer_account, class: 'FinOps::PayerAccount' do
    customer_id { SecureRandom.uuid }
    sequence(:available_funds_account) do
      "liabilities:customer-deposits:#{customer_id}:available"
    end
    sequence(:reserved_funds_account) do
      "liabilities:customer-deposits:#{customer_id}:reserved"
    end
  end
end
