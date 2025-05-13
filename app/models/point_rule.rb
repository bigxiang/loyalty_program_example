class PointRule < ApplicationRecord
  include OwnedByClient

  validates :name, presence: true, uniqueness: { scope: :client_id }
  validates :level, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :conditions, presence: true
  validates :actions, presence: true
  validates :active, inclusion: { in: [ true, false ] }
end
