### Accounting
[
  [ :asset, "1100", "assets:payment-processor-balance" ]
].each do |category, code, label|
  Accounting::Interface.new.create_account(category:, code:, label:)
end
