FactoryBot.define do
  factory :point_rule do
    client { Current.client! }
    sequence(:name) { |n| "Rule #{n}" }
    level { 1 }
    conditions { { min_spend: 100 } }
    actions { { points_per_dollar: 0.1 } }
    active { true }

    trait :point_earning_level_1 do
      level { 1 }
      name { "Point Earning Level 1" }
      conditions { { transaction: { amount_in_cents: { gte: 10000 } } } }
      actions { { points: 10, per: 10000 } }
    end

    trait :point_earning_level_2 do
      level { 2 }
      name { "Point Earning Level 2" }
      conditions { { transaction: { is_foreign: { eq: true } } } }
      actions { { multiplier: 1 } }
    end
  end
end
