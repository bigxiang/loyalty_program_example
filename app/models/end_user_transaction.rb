class EndUserTransaction < ApplicationRecord
  include OwnedByClient

  belongs_to :end_user

  validates :transaction_identifier, presence: true, uniqueness: { scope: :client_id }
  validates :is_foreign, inclusion: { in: [ true, false ] }
  validates :amount_in_cents, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :points_earned, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def available_point_rules
    PointRule.active.where("level <= ?", end_user.level)
  end
end
