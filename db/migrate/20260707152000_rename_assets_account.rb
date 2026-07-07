class RenameAssetsAccount < ActiveRecord::Migration[8.1]
  OLD_NAME = "assets:cash:payment-processor-balance"
  NEW_NAME = "assets:current:payment-processor-balance"

  def up
    rename_account(OLD_NAME, NEW_NAME)
  end

  def down
    rename_account(NEW_NAME, OLD_NAME)
  end

  private

  def rename_account(from, to)
    execute(<<~SQL)
      UPDATE accounting_accounts SET label = '#{to}' WHERE label = '#{from}'
    SQL
  end
end
