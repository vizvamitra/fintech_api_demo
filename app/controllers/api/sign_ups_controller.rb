module Api
  class SignUpsController < ApiController
    skip_before_action :authenticate!

    def create
      Api::SignUps::Create.new.call(**create_params)
      head :created
    end

    private

    def create_params
      params.require(:sign_up).permit(:email).to_h.symbolize_keys
    end
  end
end
