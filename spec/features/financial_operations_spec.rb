require "rails_helper"

RSpec.describe "Financial operations", type: :feature do
  scenario "financial operations" do
    given_two_clients_with_zero_balances

    then_first_client_balance_should_be(0)
    and_second_client_balance_should_be(0)
    and_both_clients_should_be_searchable_by_email

    when_first_client_deposits_funds(amount: 200)
    then_first_client_balance_should_be(200)
    and_first_client_should_see_the_deposit(amount: 200)

    when_first_client_transfers_money_to_second(amount: 100)
    then_first_client_balance_should_be(100)
    and_second_client_balance_should_be(100)
    and_first_client_should_see_outgoing_transfer_to_second_client(amount: 100)
    and_second_client_should_see_incoming_transfer_from_first_client(amount: 100)

    when_second_client_withdraws_funds(amount: 50)
    then_second_client_balance_should_be(50)
    and_second_client_should_see_withdrawal(amount: 50)
  end

  ### Context ###

  let(:emails) { [ "test@example.com", "test2@example.com" ] }

  before do
    Accounting::Interface.new.create_account(
      category: :asset,
      code: "1110",
      label: "assets:current:payment-processor-receivables"
    )
  end

  ### Steps ###

  def given_two_clients_with_zero_balances
    emails.each { |email| sign_up(email:) }

    @clients = [
      CX::Client.find_by!(public_email: emails[0]),
      CX::Client.find_by!(public_email: emails[1])
    ]
  end

  ### When

  def when_first_client_deposits_funds(amount:)
    sign_in(@clients[0]) do
      @deposit = create_deposit(amount_cents: amount * 100)
      expect(@deposit).not_to be_nil
    end
  end

  def when_first_client_transfers_money_to_second(amount:)
    sign_in(@clients[0]) do
      @transfer = create_transfer(
        amount_cents: amount * 100,
        receiver_id: @clients[1]["public_id"]
      )
      expect(@transfer).not_to be_nil
    end
  end

  def when_second_client_withdraws_funds(amount:)
    sign_in(@clients[1]) do
      @withdrawal = create_withdrawal(amount_cents: amount * 100)
      expect(@withdrawal).not_to be_nil
    end
  end

  ### Then

  def then_first_client_balance_should_be(amount)
    sign_in(@clients[0]) do
      client = fetch_current_client
      expect(client).not_to be_nil
      expect(client["balance_cents"]).to eq(amount * 100)
    end
  end

  def then_second_client_balance_should_be(amount)
    sign_in(@clients[1]) do
      client = fetch_current_client
      expect(client).not_to be_nil
      expect(client["balance_cents"]).to eq(amount * 100)
    end
  end

  alias :and_second_client_balance_should_be :then_second_client_balance_should_be

  def and_both_clients_should_be_searchable_by_email
    sign_in(@clients[0]) do
      client = search_client(email: emails[1])
      expect(client).not_to be_nil
      expect(client["public_email"]).to eq(emails[1])
    end

    sign_in(@clients[1]) do
      client = search_client(email: emails[0])
      expect(client).not_to be_nil
      expect(client["public_email"]).to eq(emails[0])
    end
  end

  def and_first_client_should_see_the_deposit(amount:)
    sign_in(@clients[0]) do
      movements = fetch_money_movements

      expect(movements).to be_a(Array)
      expect(movements).to include(include(
        "kind" => "deposit",
        "reference" => @deposit["public_id"],
        "amount_cents" => amount * 100
      ))
    end
  end

  def and_first_client_should_see_outgoing_transfer_to_second_client(amount:)
    sign_in(@clients[0]) do
      movements = fetch_money_movements

      expect(movements).to be_a(Array)
      expect(movements).to include(include(
        "kind" => "outgoing_transfer",
        "reference" => @transfer["public_id"],
        "amount_cents" => amount * 100,
        "sender_email" => nil
      ))
    end
  end

  def and_second_client_should_see_incoming_transfer_from_first_client(amount:)
    sign_in(@clients[1]) do
      movements = fetch_money_movements

      expect(movements).to be_a(Array)
      expect(movements).to include(include(
        "kind" => "incoming_transfer",
        "reference" => @transfer["public_id"],
        "amount_cents" => amount * 100,
        "sender_email" => @clients[0].public_email
      ))
    end
  end

  def and_second_client_should_see_withdrawal(amount:)
    sign_in(@clients[1]) do
      movements = fetch_money_movements

      expect(movements).to be_a(Array)
      expect(movements).to include(include(
        "kind" => "withdrawal",
        "reference" => @withdrawal["public_id"],
        "amount_cents" => amount * 100
      ))
    end
  end
end
