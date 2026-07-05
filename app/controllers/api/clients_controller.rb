module Api
  class ClientsController < ApiController
    def show
      client = ::CX::Client.public_find(current_credentials.client_id)
      payer = ::FinOps::PayerAccount.find_by!(client_id: client.public_id)

      balance = accounting.read_account_balance(label: payer.available_funds_account)

      render json: serialize(client, balance)
    end

    private

    def accounting
      ::Accounting::Interface.new
    end

    def serialize(client, balance)
      ClientSerializer.new(client, params: { balance_cents: balance })
    end
  end
end
