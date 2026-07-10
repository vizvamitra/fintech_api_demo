module FinOps
  Error = Class.new(StandardError)
  AmountInvalidError = Class.new(Error)
  AmountOutOfRangeError = Class.new(Error)
  SelfTransferError = Class.new(Error)
  InsufficientFundsError = Class.new(Error)

  def self.table_name_prefix = "fin_ops_"
end
