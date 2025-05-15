FactoryBot.define do
  factory :reward_rule do
    client { Current.client! }
    sequence(:name) { |n| "Rule #{n}" }
    level { 1 }
    conditions { { user: { monthly_points: { gte: 100 } } } }
    actions { { name: 'free_coffee', quantity: 1 } }
    repeat_condition { {} }
    active { true }

    trait :free_coffee_level_1 do
      level { 1 }
      name { "Free Coffee Level 1" }
      conditions { { user: { monthly_points: { gte: 100 } } } }
      repeat_condition { { type: 'monthly' } }
      actions { { name: 'free_coffee', quantity: 1 } }
    end

    trait :free_coffee_level_2 do
      level { 2 }
      name { "Free Coffee Level 2" }
      conditions { { user: { birthday_in_month: { eq: true } } } }
      repeat_condition { { type: 'yearly' } }
      actions { { name: 'free_coffee', quantity: 1 } }
    end

    trait :free_movie_ticket_level_2 do
      level { 2 }
      name { "Free Movie Ticket Level 2" }
      conditions { { user: { registered_at: { gte: '{current.months_ago(2)}' }, total_spent_in_cents: { gt: 100_000 } } } }
      actions { { name: 'free_movie_ticket', quantity: 1 } }
    end
  end
end
