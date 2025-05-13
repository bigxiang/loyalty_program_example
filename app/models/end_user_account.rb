class EndUserAccount < ApplicationRecord
  include OwnedByClient

  belongs_to :end_user

  validates :end_user, uniqueness: { scope: :client_id }
  validates :level, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :current_points, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :total_spent_in_cents, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def monthly_points(current_time = Time.zone.now)
    end_user
      .transactions
      .where(created_at: current_time.beginning_of_month..current_time.end_of_month)
      .sum(:points_earned)
  end
end
