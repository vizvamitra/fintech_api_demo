module Api
  module FinOps
    class WithdrawalsController < ApiController
      def create
        withdrawal = Withdrawals::Create.new.call(**create_params.to_h.symbolize_keys)
        render status: :created, json: Alba.serialize(withdrawal)
      end

      private

      def create_params
        {
          **params.require(:withdrawal).permit(:amount_cents),
          customer_id: current_credentials.customer_id
        }
      end
    end
  end
end
