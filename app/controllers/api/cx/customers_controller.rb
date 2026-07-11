module Api
  module CX
    class CustomersController < ApiController
      def show
        customer = ::CX::Customer.find_by!(public_email: params.require(:public_email))
        render json: Alba.serialize(customer)
      end
    end
  end
end
