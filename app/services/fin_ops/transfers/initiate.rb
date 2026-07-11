module FinOps
  module Transfers
    class Initiate
      def initialize(record_transfer: Bookkeeping::RecordTransfer.new,
                     min_amount: Rails.configuration.x.fin_ops.min_transfer_amount,
                     max_amount: Rails.configuration.x.fin_ops.max_transfer_amount,
                     accounting: Accounting::Interface.new,
                     customers: CX::Interface.new)
        @_record_transfer = record_transfer
        @_accounting = accounting
        @_customers = customers
        @_min_amount = min_amount
        @_max_amount = max_amount
      end

      # @param sender_id [UUID]
      # @param receiver_id [UUID]
      # @param amount_cents [Integer]
      #
      # @return [FinOps::Transfer]
      # @raise [ActiveRecord::RecordNotFound]
      # @raise [FinOps::SelfTransferError]
      # @raise [FinOps::AmountOutOfRangeError]
      # @raise [FinOps::InsufficientFundsError]
      #
      def call(sender_id:, receiver_id:, amount_cents:)
        raise SelfTransferError if sender_id == receiver_id
        raise AmountOutOfRangeError unless (_min_amount.._max_amount).cover?(amount_cents)

        sender = find_payer(sender_id)
        receiver = find_payer(receiver_id)

        ApplicationRecord.transaction do
          sender.lock!

          balance = read_available_balance(sender)
          raise InsufficientFundsError if balance < amount_cents

          transfer = create_transfer(sender, receiver, amount_cents)
          reflect_in_accounting(sender, receiver, transfer)

          notify_cx_about_outgoing_transfer(transfer, sender)
          notify_cx_about_incoming_transfer(transfer, receiver, sender)

          transfer
        end
      end

      private

      attr_reader :_record_transfer, :_min_amount, :_max_amount, :_accounting, :_customers

      def find_payer(customer_id)
        FinOps::PayerAccount.find_by!(customer_id:)
      end

      def read_available_balance(sender)
        _accounting.read_account_balance(label: sender.available_funds_account)
      end

      def create_transfer(sender, receiver, amount_cents)
        Transfer.create!(sender:, receiver:, amount_cents:)
      end

      def reflect_in_accounting(sender, receiver, transfer)
        _record_transfer.call(sender:, receiver:, transfer:)
      end

      def notify_cx_about_outgoing_transfer(transfer, sender)
        _customers.store_money_movement(
          customer_id: sender.customer_id,
          kind: :outgoing_transfer,
          **money_movement_attributes(transfer)
        )
      end

      def notify_cx_about_incoming_transfer(transfer, receiver, sender)
        _customers.store_money_movement(
          customer_id: receiver.customer_id,
          kind: :incoming_transfer,
          sender_id: sender.customer_id,
          **money_movement_attributes(transfer)
        )
      end

      def money_movement_attributes(transfer)
        {
          reference: transfer.public_id,
          state: :settled,
          amount_cents: transfer.amount_cents,
          initiated_at: transfer.created_at,
          resolved_at: transfer.created_at
        }
      end
    end
  end
end
