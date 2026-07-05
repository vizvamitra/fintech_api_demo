module FinOps
  class Interface < Subsystems::Interface
    def create_payer_account(**args)
      with_logging { PayerAccounts::Create.new.call(**args) }
    end

    def initiate_deposit(**args)
      with_logging { Deposits::Initiate.new.call(**args) }
    end

    def initiate_withdrawal(**args)
      with_logging { Withdrawals::Initiate.new.call(**args) }
    end

    def initiate_transfer(**args)
      with_logging { Transfers::Initiate.new.call(**args) }
    end
  end
end
