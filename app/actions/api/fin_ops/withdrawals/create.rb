module Api
  module FinOps
    module Withdrawals
      class Create
        def initialize(fin_ops: ::FinOps::Interface.new)
          @_fin_ops = fin_ops
        end

        # @param customer_id [UUID]
        # @param amount_cents [Integer]
        #
        # @return [FinOps::Withdrawal]
        # @raise [ActiveRecord::RecordNotFound]
        # @raise [HttpErrors::UnprocessableContentError]
        #
        def call(customer_id:, amount_cents:)
          validate(amount_cents)

          _fin_ops.initiate_withdrawal(customer_id:, amount_cents:)
        rescue ::FinOps::AmountInvalidError
          raise HttpErrors::UnprocessableContentError, :amount_invlid
        rescue ::FinOps::AmountOutOfRangeError
          raise HttpErrors::UnprocessableContentError, :amount_out_of_range
        rescue ::FinOps::InsufficientFundsError, ::Accounting::InsufficientFundsError
          raise HttpErrors::UnprocessableContentError, :insufficient_funds
        end

        private

        attr_reader :_fin_ops

        def validate(amount_cents)
          return if amount_cents.integer?
          raise HttpErrors::UnprocessableContentError, :amount_invalid
        end
      end
    end
  end
end
