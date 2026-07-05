module FinOps
  module Withdrawals
    class Initiate
      def initialize(reserve_funds: Bookkeeping::ReserveFundsForWithdrawal.new,
                     record_withdrawal: Bookkeeping::RecordWithdrawal.new,
                     clients: CX::Interface.new)
        @_reserve_funds = reserve_funds
        @_record_withdrawal = record_withdrawal
        @_clients = clients
      end

      # @param client_id [UUID]
      # @param amount_cents [Integer]
      #
      # @return [FinOps::Withdrawal]
      # @raise [ActiveRecord::RecordNotFound]
      # @raise [FinOps::NegativeAmountError]
      #
      def call(client_id:, amount_cents:)
        raise NegativeAmountError if amount_cents < 0

        payer = FinOps::PayerAccount.find_by!(client_id:)

        # The real app would probably requre the client to set up his withdrawal method
        # first. Then, withdrawal initiation would mean:
        #
        # - createing a withdrawal record
        # - then firing an API call to the payment processor to initiate the withdrawal
        #   on their end using the configured withdrawal method
        # - then storing that withdrawal information in the DB
        # - and, finally, informing the user that their withdrawal is on the way
        #
        # After that, the withdrawal would sit in the initiated state until the webhook
        # from the payment processor arrive, informing the system about either a success
        # or a failure. On success, the system would reflect the change in the ledger, on
        # failure -- release the reserved funds
        #
        # But in this test task I skip that complexity for the sake of simplicity,
        # modeling withdrawals as if settlement happens right after the creation. With
        # this, I wanted to demonstrate fund reservations.
        #
        ApplicationRecord.transaction do
          withdrawal = crate_withdrawal(payer, amount_cents)
          reserve_funds(payer, withdrawal)
          notify_cx_about_money_movement(payer, withdrawal)

          # Withdrawal magically settles

          settle_withdrawal(withdrawal, Time.current)
          record_withdrawal(payer, withdrawal)
          notify_cx_about_money_movement(payer, withdrawal)

          withdrawal
        end
      end

      private

      attr_reader :_reserve_funds, :_record_withdrawal, :_clients

      def crate_withdrawal(payer, amount_cents)
        payer.withdrawals.create(state: :initiated, amount_cents:)
      end

      def reserve_funds(payer, withdrawal)
        _reserve_funds.call(payer:, withdrawal:)
      end

      def settle_withdrawal(withdrawal, settled_at)
        withdrawal.update!(state: :settled, settled_at:)
      end

      def record_withdrawal(payer, withdrawal)
        _record_withdrawal.call(payer:, withdrawal:)
      end

      def notify_cx_about_money_movement(payer, withdrawal)
        _clients.store_money_movement(
          client_id: payer.client_id,
          kind: :withdrawal,
          reference: withdrawal.public_id,
          state: withdrawal.initiated? ? :pending : :settled,
          amount_cents: withdrawal.amount_cents,
          initiated_at: withdrawal.created_at,
          resolved_at: withdrawal.settled_at
        )
      end
    end
  end
end
