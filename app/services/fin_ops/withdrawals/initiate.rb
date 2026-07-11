module FinOps
  module Withdrawals
    class Initiate
      def initialize(reserve_funds: Bookkeeping::ReserveFundsForWithdrawal.new,
                     record_withdrawal: Bookkeeping::RecordWithdrawal.new,
                     min_amount: Rails.configuration.x.fin_ops.min_withdrawal_amount_cents,
                     accounting: Accounting::Interface.new,
                     customers: CX::Interface.new)
        @_reserve_funds = reserve_funds
        @_record_withdrawal = record_withdrawal
        @_min_amount = min_amount
        @_accounting = accounting
        @_customers = customers
      end

      # @param customer_id [UUID]
      # @param amount_cents [Integer]
      #
      # @return [FinOps::Withdrawal]
      # @raise [ActiveRecord::RecordNotFound]
      # @raise [FinOps::AmountOutOfRangeError]
      # @raise [FinOps::InsufficientFundsError]
      #
      def call(customer_id:, amount_cents:)
        raise AmountOutOfRangeError if amount_cents < _min_amount

        payer = find_payer(customer_id)

        # The real app would probably require the customer to set up his withdrawal method
        # first. Then, withdrawal initiation would mean:
        #
        # - creating a withdrawal record
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
          payer.lock!

          balance = read_available_balance(payer)
          raise InsufficientFundsError if balance < amount_cents

          withdrawal = create_withdrawal(payer, amount_cents)
          reserve_funds(payer, withdrawal)
          notify_cx_about_money_movement(payer, withdrawal)

          # Withdrawal magically settles

          mark_settled(withdrawal)
          transfer_funds(payer, withdrawal)
          notify_cx_about_money_movement(payer, withdrawal)

          withdrawal
        end
      end

      private

      attr_reader :_reserve_funds, :_record_withdrawal, :_min_amount, :_accounting,
                  :_customers

      def find_payer(customer_id)
        FinOps::PayerAccount.find_by!(customer_id:)
      end

      def read_available_balance(sender)
        _accounting.read_account_balance(label: sender.available_funds_account)
      end

      def create_withdrawal(payer, amount_cents)
        payer.withdrawals.create!(state: :initiated, amount_cents:)
      end

      def reserve_funds(payer, withdrawal)
        _reserve_funds.call(payer:, withdrawal:)
      end

      def mark_settled(withdrawal)
        withdrawal.update!(state: :settled, settled_at: Time.current)
      end

      def transfer_funds(payer, withdrawal)
        _record_withdrawal.call(payer:, withdrawal:)
      end

      def notify_cx_about_money_movement(payer, withdrawal)
        _customers.store_money_movement(
          customer_id: payer.customer_id,
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
