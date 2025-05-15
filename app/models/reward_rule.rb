class RewardRule < ApplicationRecord
  include OwnedByClient

  has_many :end_user_rewards

  validates :name, presence: true, uniqueness: { scope: :client_id }
  validates :level, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :conditions, presence: true
  validates :actions, presence: true
  validates :active, inclusion: { in: [ true, false ] }

  scope :active, -> { where(active: true) }
  scope :available_for, ->(user) { active.where("level <= ?", user.level) }
end
