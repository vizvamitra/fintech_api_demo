### Accounting
[
  [ :asset, :debit, 1100, "assets:payment-processor-balance" ]
].each do |category, natural_balance, code, label|
  Accounting::Account.create(category:, natural_balance:, code:, label:)
end
