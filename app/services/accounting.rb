module Accounting
  Error = Class.new(StandardError)
  UnbalancedJournalEntryError = Class.new(Error)
  InsufficientBalanceError = Class.new(Error)

  def self.table_name_prefix = "accounting_"
end
