Rails.application.routes.draw do
  namespace "api" do
    resources :sign_ups, only: %i[create]
    resources :sign_ins, only: %i[create]
    resource :me, only: %i[show], controller: "me"

    namespace "cx" do
      resource :customer, only: %i[show]
      resources :money_movements, only: %i[index]
    end

    namespace "fin_ops" do
      resources :deposits, only: %i[create]
      resources :withdrawals, only: %i[create]
      resources :transfers, only: %i[create]
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
