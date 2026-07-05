module Api
  module FinOps
    class WithdrawalsController < ApiController
      def create
        withdrawal = Withdrawals::Create.new.call(**create_params.to_h.symbolize_keys)
        render :created, json: Alba.serialize(withdrawal)
      end

      private

      def create_params
        {
          **params.require(:withdrawal).permit(:amount_cents),
          client_id: current_credentials.client_id
        }
      end
    end
  end
end
