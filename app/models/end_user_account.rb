class EndUserAccount < ApplicationRecord
  include OwnedByClient

  belongs_to :end_user

  validates :end_user, presence: true, uniqueness: { scope: :client_id }
  validates :level, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :current_points, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :monthly_points, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :total_spent_in_cents, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
