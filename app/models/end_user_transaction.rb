class EndUserTransaction < ApplicationRecord
  belongs_to :end_user
  belongs_to :client

  validates :transaction_identifier, presence: true, uniqueness: { scope: :client_id }
  validates :end_user, presence: true
  validates :is_foreign, inclusion: { in: [ true, false ] }
  validates :amount_in_cents, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :points_earned, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
