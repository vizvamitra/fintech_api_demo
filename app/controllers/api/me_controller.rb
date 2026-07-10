module Api
  class MeController < ApiController
    def show
      result = Api::Me::Show.new.call(client_id: current_credentials.client_id)
      render json: serialize(result)
    end

    private

    def serialize(result)
      result => { client:, balance_cents: }
      CurrentClientSerializer.new(client, params: { balance_cents: })
    end
  end
end
