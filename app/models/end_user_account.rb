class EndUserAccount < ApplicationRecord
  include OwnedByClient

  belongs_to :user, class_name: "EndUser", foreign_key: "end_user_id"

  validates :user, uniqueness: { scope: :client_id }
  validates :level, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :current_points, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :total_spent_in_cents, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def monthly_points(current_time = Time.zone.now)
    user
      .transactions
      .where(created_at: current_time.beginning_of_month..current_time.end_of_month)
      .sum(:points_earned)
  end
end
