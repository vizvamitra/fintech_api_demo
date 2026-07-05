### Accounting
[
  [ :asset, "1110", "assets:cash:payment-processor-balance" ]
].each do |category, code, label|
  Accounting::Interface.new.create_account(category:, code:, label:)
end
