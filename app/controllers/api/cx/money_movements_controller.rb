module Api
  module CX
    class MoneyMovementsController < ApiController
      def index
        customer = ::CX::Customer.public_find(current_credentials.customer_id)
        money_movements = customer.money_movements.order(initiated_at: :desc)

        render json: Alba.serialize(money_movements, root_key: :data)
      end
    end
  end
end
