module Api
  module FinOps
    class DepositsController < ApiController
      def create
        deposit = Deposits::Create.new.call(**create_params.to_h.symbolize_keys)
        render :created, json: Alba.serialize(deposit)
      end

      private

      def create_params
        {
          **params.require(:deposit).permit(:amount_cents),
          client_id: current_credentials.client_id
        }
      end
    end
  end
end
