module Api
  class ClientsController < ApiController
    def show
      client = CX::Client.public_find(current_credentials.client_id)
      balance = 123 # acounting.read_client_deposit_balance(client.public_id)

      render json: serialize(client, balance:)
    end

    private

    # def acounting
    #   Accounting::Interface.new
    # end

    def serialize(client, **deposit)
      ClientSerializer.new(client, params: { deposit: })
    end
  end
end
