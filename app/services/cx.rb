# CX stands for Client Experience
#
module CX
  Error = Class.new(StandardError)
  EmailTakenError = Class.new(Error)

  def self.table_name_prefix = "cx_"
end
