module Api
  module FinOps
    module Transfers
      class Create
        def initialize(fin_ops: ::FinOps::Interface.new)
          @_fin_ops = fin_ops
        end

        # @param client_id [UUID]
        # @param receiver_id [UUID]
        # @param amount_cents [Integer]
        #
        # @return [FinOps::Transfer]
        # @raise [ActiveRecord::RecordNotFound]
        # @raise [HttpErrors::UnprocessableContentError]
        #
        def call(client_id:, receiver_id:, amount_cents:)
          validate(amount_cents)

          _fin_ops.initiate_transfer(sender_id: client_id, receiver_id:, amount_cents:)
        rescue ::FinOps::AmountOutOfRangeError
          raise HttpErrors::UnprocessableContentError, :amount_out_of_range
        rescue ::FinOps::AmountInvalidError
          raise HttpErrors::UnprocessableContentError, :amount_invlid
        rescue ::FinOps::SelfTransferError
          raise HttpErrors::UnprocessableContentError, :self_transfer
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
