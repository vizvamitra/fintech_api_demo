module Api
  module Me
    class Show
      def initialize(accounting: ::Accounting::Interface.new)
        @_accounting = accounting
      end

      # @param customer_id [UUID]
      #
      # @return [Hash{customer: CX::Customer, balance_cents: Integer}]
      #
      def call(customer_id:)
        customer = ::CX::Customer.public_find(customer_id)
        payer = ::FinOps::PayerAccount.find_by!(customer_id: customer.public_id)

        balance = read_balance(payer)

        { customer:, balance_cents: balance }
      end

      attr_reader :_accounting

      def read_balance(payer)
        _accounting.read_account_balance(label: payer.available_funds_account)
      end
    end
  end
end
