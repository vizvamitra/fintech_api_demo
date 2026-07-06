require "rack/test"

module ApiHelpers
  include Rack::Test::Methods

  ### Authentication

  def sign_up(email:)
    post("api/sign_ups", params: { email: })
  end

  def sign_in(client)
    credentials = Credentials.find_by!(client_id: client["public_id"])

    params = { email: credentials.email }
    token = post("/api/sign_ins", params:).dig('data', 'access_token')

    header('Authorization', "Bearer #{token}")

    if block_given?
      yield
      sign_out
    end
  end

  def sign_out
    header('Authorization', nil)
  end

  ### Current Client

  def fetch_current_client
    get("api/me")["data"]
  end

  ### Client Experience

  def search_client(email:)
    get("api/cx/client", params: { public_email: email })["data"]
  end

  def fetch_money_movements
    get("api/cx/money_movements")["data"]
  end

  ### Financial Operations

  def create_deposit(amount_cents:)
    params = { amount_cents: }
    post("api/fin_ops/deposits", params:)["data"]
  end

  def create_withdrawal(amount_cents:)
    params = { amount_cents: }
    post("api/fin_ops/withdrawals", params:)["data"]
  end

  def create_transfer(amount_cents:, receiver_id:)
    params = { amount_cents:, receiver_id: }
    post("api/fin_ops/transfers", params:)["data"]
  end

  ### Low-level stuff

  def app
    Rails.application
  end

  %i[get post put patch delete head].each do |http_method|
    define_method(http_method) do |path, headers: {}, params: {}|
      header("Content-Type", "application/json")
      params = params.to_json if %i[post put patch].include?(http_method)

      result = super(path, params)

      if result.headers['content-type'] =~ /json/
        JSON.parse(result.body)
      else
        result.body
      end
    end
  end
end
