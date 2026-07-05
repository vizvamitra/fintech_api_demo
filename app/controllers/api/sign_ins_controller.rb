module Api
  class SignInsController < ApiController
    skip_before_action :authenticate!

    def create
      access_token = Api::SignIns::Create.new.call(**create_params)
      render status: :created, json: AccessTokenSerializer.new(access_token)
    end

    private

    def create_params
      params.require(:sign_in).permit(:email).to_h.symbolize_keys
    end
  end
end
