class RenameTransactionIdentifierToIssuranceIdentifierInEndUserRewards < ActiveRecord::Migration[8.0]
  def change
    rename_column :end_user_rewards, :transaction_identifier, :issurance_identifier
  end
end
