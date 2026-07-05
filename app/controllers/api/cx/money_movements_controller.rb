module Api
  module CX
    class MoneyMovementsController < ApiController
      def index
        client = ::CX::Client.public_find(current_credentials.client_id)
        money_movements = client.money_movements.order(initiated_at: :desc)

        render :ok, json: Alba.serialize(money_movements, root_key: :data)
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
