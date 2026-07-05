module Accounting
  class Interface < Subsystems::Interface
    def create_account(**args)
      with_logging { Accounts::Create.new.call(**args) }
    end

    def read_account_balance(**args)
      Accounts::ReadBalance.new.call(**args)
    end

    def create_journal_entry(**args)
      with_logging { JournalEntries::Create.new.call(**args) }
    end
  end
end
