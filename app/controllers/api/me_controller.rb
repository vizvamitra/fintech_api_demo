module Api
  class MeController < ApiController
    def show
      result = Api::Me::Show.new.call(customer_id: current_credentials.customer_id)
      render json: serialize(result)
    end

    private

    def serialize(result)
      result => { customer:, balance_cents: }
      CurrentCustomerSerializer.new(customer, params: { balance_cents: })
    end
  end
end
