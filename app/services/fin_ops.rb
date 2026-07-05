module FinOps
  Error = Class.new(StandardError)
  NegativeAmountError = Class.new(Error)

  def self.table_name_prefix = "fin_ops_"
end
