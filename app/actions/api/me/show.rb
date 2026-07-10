module Api
  module Me
    class Show
      def initialize(accounting: ::Accounting::Interface.new)
        @_accounting = accounting
      end

      # @param client_id [UUID]
      #
      # @return [Hash{client: CX::Clinet, balance_cents: Integer}]
      #
      def call(client_id:)
        client = ::CX::Client.public_find(client_id)
        payer = ::FinOps::PayerAccount.find_by!(client_id: client.public_id)

        balance = read_balance(payer)

        { client:, balance_cents: balance }
      end

      attr_reader :_accounting

      def read_balance(payer)
        _accounting.read_account_balance(label: payer.available_funds_account)
      end
    end
  end
end
