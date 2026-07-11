module Api
  module FinOps
    class DepositsController < ApiController
      def create
        deposit = Deposits::Create.new.call(**create_params.to_h.symbolize_keys)
        render status: :created, json: Alba.serialize(deposit)
      end

      private

      def create_params
        {
          **params.require(:deposit).permit(:amount_cents),
          customer_id: current_credentials.customer_id
        }
      end
    end
  end
end
