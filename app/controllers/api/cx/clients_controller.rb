module Api
  module CX
    class ClientsController < ApiController
      def show
        client = ::CX::Client.find_by!(public_email: params.require(:public_email))
        render json: Alba.serialize(client)
      end
    end
  end
end
