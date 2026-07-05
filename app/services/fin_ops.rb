module FinOps
  Error = Class.new(StandardError)
  AmountBelowMinimumError = Class.new(Error)
  InsufficientFundsError = Class.new(Error)

  def self.table_name_prefix = "fin_ops_"
end
