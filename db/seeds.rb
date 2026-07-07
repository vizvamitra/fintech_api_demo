### Accounting
[
  [ :asset, "1110", "assets:current:payment-processor-receivables" ]
].each do |category, code, label|
  Accounting::Interface.new.create_account(category:, code:, label:)
end
