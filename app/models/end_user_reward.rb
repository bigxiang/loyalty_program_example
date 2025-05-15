class EndUserReward < ApplicationRecord
  include OwnedByClient
  include HasIssuranceIdentifier

  belongs_to :user, class_name: "EndUser", foreign_key: :end_user_id
  belongs_to :reward_rule

  validates :issued_at, presence: true
  validates :issurance_identifier, presence: true, uniqueness: { scope: :client_id }

  scope :for_user_and_rule, ->(user_id, rule_id) { where(end_user_id: user_id, reward_rule_id: rule_id) }
  scope :ordered_by_issued_at, -> { order(issued_at: :desc) }
end
