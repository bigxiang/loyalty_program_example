class EndUser < ApplicationRecord
  include OwnedByClient

  validates :identifier, presence: true, uniqueness: { scope: :client_id }
  validates :birthday, presence: true
  validates :registered_at, presence: true
  validates :client, presence: true
end
