module CX
  class Client < ApplicationRecord
    def self.public_find(public_id)
      find_by!(public_id:)
    end
  end
end
