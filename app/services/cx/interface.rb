module CX
  class Interface < Subsystems::Interface
    def create_customer(**args)
      with_logging { CX::Customers::Create.new.call(**args) }
    end

    def store_money_movement(**args)
      with_logging { CX::MoneyMovements::Store.new.call(**args) }
    end
  end
end
