module Api
  module FinOps
    module Deposits
      class Create
        def initialize(fin_ops: ::FinOps::Interface.new)
          @_fin_ops = fin_ops
        end

        # @param client_id [UUID]
        # @param amount_cents [Integer]
        #
        # @return [FinOps::Deposit]
        # @raise [ActiveRecord::RecordNotFound]
        # @raise [HttpErrors::UnprocessableContentError]
        #
        def call(client_id:, amount_cents:)
          _fin_ops.initiate_deposit(client_id:, amount_cents:)
        rescue ::FinOps::NegativeAmountError
          raise HttpErrors::UnprocessableContentError, :negative_balance
        end

        private

        attr_reader :_fin_ops
      end
    end
  end
end
