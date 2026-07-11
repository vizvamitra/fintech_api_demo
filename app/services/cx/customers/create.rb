module CX
  module Customers
    class Create
      def initialize(fin_ops: FinOps::Interface.new)
        @_fin_ops = fin_ops
      end

      # @param public_email [String]
      #
      # @return [CX::Customer]
      # @raise [CX::EmailTakenError]
      # @raise [ActiveRecord::RecordInvalid]
      #
      def call(public_email:)
        ApplicationRecord.transaction do
          customer = Customer.create!(public_email:)
          _fin_ops.create_payer_account(customer_id: customer.public_id)

          customer
        end
      rescue ActiveRecord::RecordNotUnique
        raise EmailTakenError
      end

      private

      attr_reader :_fin_ops
    end
  end
end
