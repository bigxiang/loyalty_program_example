FactoryBot.define do
  factory :end_user_reward do
    client { Current.client! }
    association :user, factory: :end_user
    association :reward_rule
    issued_at { Time.current }
    issurance_identifier { EndUserReward.generate_issurance_identifier(user.id, reward_rule.id) }
  end
end
