module FinOps
  module Transfers
    class Initiate
      def initialize(record_transfer: Bookkeeping::RecordTransfer.new,
                     accounting: Accounting::Interface.new,
                     clients: CX::Interface.new)
        @_record_transfer = record_transfer
        @_accounting = accounting
        @_clients = clients
      end

      # @param sender_id [UUID]
      # @param receiver_id [UUID]
      # @param amount_cents [Integer]
      #
      # @return [FinOps::Transfer]
      # @raise [ActiveRecord::RecordNotFound]
      # @raise [FinOps::AmountBelowMinimumError]
      # @raise [FinOps::SelfTransferError]
      # @raise [FinOps::InsufficientFundsError]
      #
      def call(sender_id:, receiver_id:, amount_cents:)
        raise AmountBelowMinimumError if amount_cents <= 0
        raise SelfTransferError if sender_id == receiver_id

        sender = find_payer(sender_id)
        receiver = find_payer(receiver_id)

        balance = read_available_balance(sender)
        raise InsufficientFundsError if balance < amount_cents

        ApplicationRecord.transaction do
          transfer = create_transfer(sender, receiver, amount_cents)
          reflect_in_accounting(sender, receiver, transfer)

          notify_cx_about_money_movement(sender, :outgoing_transfer, transfer)
          notify_cx_about_money_movement(receiver, :incoming_transfer, transfer)

          transfer
        end
      end

      private

      attr_reader :_record_transfer, :_accounting, :_clients

      def find_payer(client_id)
        FinOps::PayerAccount.find_by!(client_id:)
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

      def notify_cx_about_money_movement(payer, kind, transfer)
        _clients.store_money_movement(
          client_id: payer.client_id,
          kind:,
          reference: transfer.public_id,
          state: :settled,
          amount_cents: transfer.amount_cents,
          initiated_at: transfer.created_at,
          resolved_at: transfer.created_at
        )
      end
    end
  end
end
