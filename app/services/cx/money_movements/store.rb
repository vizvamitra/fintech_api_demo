module CX
  module MoneyMovements
    class Store
      ATTRIBUTES = %i[amount_cents state initiated_at resolved_at error]

      # @param client_id [UUID]
      # @param kind [Symbol]
      # @param reference [UUID]
      # @param sender_id [UUID, nil]
      # @param attributes [Hash]
      # @option attributes [Integer] amount_cents
      # @option attributes [Symbol] state
      # @option attributes [DateTime] initiated_at
      # @option attributes [String, nil] error
      # @option attributes [DateTime, nil] resolved_at
      #
      # @return [CX::MoneyMovement]
      #
      def call(client_id:, kind:, reference:, sender_id: nil, **attributes)
        client = Client.public_find(client_id)
        sender = Client.public_find(sender_id) if sender_id

        client
          .money_movements
          .create_with(attributes.slice(*ATTRIBUTES))
          .create_or_find_by(client_id: client.id, kind:, reference:)
          .update!(sender:, **attributes.slice(*ATTRIBUTES))
      end
    end
  end
end
