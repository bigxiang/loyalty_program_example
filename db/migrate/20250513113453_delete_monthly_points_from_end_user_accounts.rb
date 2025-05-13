class DeleteMonthlyPointsFromEndUserAccounts < ActiveRecord::Migration[8.0]
  def change
    remove_column :end_user_accounts, :monthly_points, :integer, null: false, default: 0
  end
end
