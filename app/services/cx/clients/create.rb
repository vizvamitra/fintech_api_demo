module CX
  module Clients
    class Create
      # @param contact_email [String]
      #
      # @return [CX::Account]
      #
      def call(contact_email:)
        ApplicationRecord.transaction do
          account = Client.create(contact_email:)

          # create payer account and accounting stuff

          account
        end
      end
    end
  end
end
