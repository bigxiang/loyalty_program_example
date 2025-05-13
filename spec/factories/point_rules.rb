FactoryBot.define do
  factory :point_rule do
    client { Current.client! }
    sequence(:name) { |n| "Rule #{n}" }
    level { 1 }
    conditions { { min_spend: 100 } }
    actions { { points_per_dollar: 0.1 } }
    active { true }
  end
end
