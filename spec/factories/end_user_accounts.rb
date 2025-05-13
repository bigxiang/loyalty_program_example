FactoryBot.define do
  factory :end_user_account do
    association :end_user
    client { Current.client! }
    level { 1 }
    current_points { 100 }
    total_spent_in_cents { 10000 }
  end
end
