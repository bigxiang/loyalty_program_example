class EndUser < ApplicationRecord
  include OwnedByClient

  has_one :end_user_account
  has_many :end_user_transactions

  delegate :level, to: :end_user_account

  validates :identifier, presence: true, uniqueness: { scope: :client_id }
  validates :birthday, presence: true
  validates :registered_at, presence: true
end
