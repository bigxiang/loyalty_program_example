class EndUser < ApplicationRecord
  include OwnedByClient

  MIN_LEVEL = 1

  has_one :account, class_name: "EndUserAccount"
  has_many :transactions, class_name: "EndUserTransaction"
  has_many :end_user_rewards

  delegate :level, :current_points, :monthly_points, :total_spent_in_cents, to: :account

  validates :identifier, presence: true, uniqueness: { scope: :client_id }
  validates :birthday, presence: true
  validates :registered_at, presence: true

  def birthday_in_month?
    birthday.month == Time.current.month
  end
  alias birthday_in_month birthday_in_month?
end
