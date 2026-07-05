module Accounting
  Account = Data.define(:label)

  class Interface < Subsystems::Interface
    def create_account(**args)
      # with_logging { Accounts::Create.new.call(**args) }
      Account.new(args.slice(:label))
    end

    def read_account_balance(**args)
      # Accounts::ReadBalance.new.call(**args)
      100500
    end

    def create_journal_entry(**args)
      # with_logging { JournalEntries::Create.new.call(**args) }
      :ok
    end
  end
end
