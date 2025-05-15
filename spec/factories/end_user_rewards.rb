FactoryBot.define do
  factory :end_user_reward do
    client { Current.client! }
    association :user, factory: :end_user
    association :reward_rule
    issued_at { Time.current }
    transaction_identifier { Digest::MD5.hexdigest("#{user.id}:#{reward_rule.id}:#{Time.current.beginning_of_day.to_i}") }
  end
end
