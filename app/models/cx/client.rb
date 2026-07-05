module CX
  class Client < ApplicationRecord
    has_many :money_movements, dependent: :destroy

    def self.public_find(public_id)
      find_by!(public_id:)
    end
  end
end
