module FinOps
  module Deposits
    class Initiate
      def initialize(record_deposit: Bookkeeping::RecordDeposit.new,
                     clients: CX::Interface.new)
        @_record_deposit = record_deposit
        @_clients = clients
      end

      # @param client_id [UUID]
      # @param amount_cents [Integer]
      #
      # @return [FinOps::Deposit]
      # @raise [ActiveRecord::RecordNotFound]
      # @raise [FinOps::AmountBelowMinimumError]
      #
      def call(client_id:, amount_cents:)
        raise AmountBelowMinimumError if amount_cents <= 0

        payer = FinOps::PayerAccount.find_by!(client_id:)

        # The real app would probably work with some third-party payment processor, which
        # would make deposits asynchronous and require the app to track their life cycles.
        # In that case, initiating a deposit would mean:
        #
        # - creating a deposit record
        # - then firing an API request to the payment processor to create some kind
        #   of a payment intent on their end
        # - then storing that payment intent information in your DB
        # - and providing the user with an URL to the payment processor website to
        #   proceed with the payment
        #
        # After that, the deposit would sit in the initiated state until the webhook from
        # the payment processor informing the system about the intent state changes.
        # Whenever the intent is fulfilled, meaning that the funds are on your account,
        # only then you would record anything at your ledger.
        #
        # But in this test task I skip that complexity for the sake of simplicity,
        # modeling deposits as if they are instant and don't have any life cycle
        #
        ApplicationRecord.transaction do
          deposit = create_deposit(payer, amount_cents)
          reflect_in_accounting(payer, deposit)

          notify_cx_about_money_movement(payer, deposit)

          deposit
        end
      end

      private

      attr_reader :_record_deposit, :_clients

      def create_deposit(payer, amount_cents)
        payer.deposits.create!(amount_cents:)
      end

      def reflect_in_accounting(payer, deposit)
        _record_deposit.call(payer:, deposit:)
      end

      def notify_cx_about_money_movement(payer, deposit)
        _clients.store_money_movement(
          client_id: payer.client_id,
          kind: :deposit,
          reference: deposit.public_id,
          state: :settled,
          amount_cents: deposit.amount_cents,
          initiated_at: deposit.created_at,
          resolved_at: deposit.created_at
        )
      end
    end
  end
end
