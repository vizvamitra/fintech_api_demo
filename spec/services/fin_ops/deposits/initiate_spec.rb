require "rails_helper"

RSpec.describe FinOps::Deposits::Initiate do
  subject(:initiate) do
    described_class.new(record_deposit:, clients:).call(client_id:, amount_cents:)
  end

  let(:record_deposit) { instance_spy("FinOps::Bookkeeping::RecordDeposit") }
  let(:clients) { instance_spy("CX::Interface") }

  let!(:payer) { create(:fin_ops_payer_account) }

  let(:amount_cents) { 100_00 }
  let(:client_id) { payer.client_id }
  let(:record_deposit_response) { ->(*) { nil } }

  before do
    allow(record_deposit).to receive(:call, &record_deposit_response)
    allow(clients).to receive(:store_money_movement)
  end

  it "on success" do
    expect(initiate)
      .to be_a(FinOps::Deposit)
      .and have_attributes(payer:, amount_cents:)

    expect(record_deposit).to have_received(:call).with(payer:, deposit: initiate)
    expect(clients).to have_received(:store_money_movement).with(
      client_id:,
      kind: :deposit,
      reference: initiate.public_id,
      state: :settled,
      amount_cents: amount_cents,
      initiated_at: initiate.created_at,
      resolved_at: initiate.created_at
    )
  end

  context "when amount is negative" do
    let(:amount_cents) { -100_00 }
    it { expect { initiate }.to raise_error(FinOps::AmountBelowMinimumError) }
  end

  context "when payer account doesn't exist" do
    let(:client_id) { SecureRandom.uuid }
    it { expect { initiate }.to raise_error(ActiveRecord::RecordNotFound) }
  end

  context "when recording deposit fails" do
    let(:record_deposit_response) { ->(*) { raise Accounting::Error } }
    it { expect { initiate }.to raise_error(Accounting::Error) }
  end
end
