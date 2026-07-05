module Api
  module FinOps
    class TransfersController < ApiController
      def create
        transfer = Transfers::Create.new.call(**create_params.to_h.symbolize_keys)
        render status: :created, json: Alba.serialize(transfer)
      end

      private

      def create_params
        {
          **params.require(:transfer).permit(:amount_cents, :receiver_id),
          client_id: current_credentials.client_id
        }
      end
    end
  end
end
