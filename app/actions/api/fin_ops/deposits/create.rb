module Api
  module FinOps
    module Deposits
      class Create
        def initialize(fin_ops: ::FinOps::Interface.new)
          @_fin_ops = fin_ops
        end

        # @param customer_id [UUID]
        # @param amount_cents [Integer]
        #
        # @return [FinOps::Deposit]
        # @raise [ActiveRecord::RecordNotFound]
        # @raise [HttpErrors::UnprocessableContentError]
        #
        def call(customer_id:, amount_cents:)
          validate(amount_cents)

          _fin_ops.initiate_deposit(customer_id:, amount_cents: amount_cents.to_i)
        rescue ::FinOps::AmountInvalidError
          raise HttpErrors::UnprocessableContentError, :amount_invlid
        rescue ::FinOps::AmountOutOfRangeError
          raise HttpErrors::UnprocessableContentError, :amount_out_of_range
        end

        private

        attr_reader :_fin_ops

        # A better option is to use something like dry-schema to validate action input
        # types and set constraints, but I'm intentionally keeping it simple in this demo
        # app.
        #
        def validate(amount_cents)
          return if amount_cents.integer?
          raise HttpErrors::UnprocessableContentError, :amount_invalid
        end
      end
    end
  end
end
