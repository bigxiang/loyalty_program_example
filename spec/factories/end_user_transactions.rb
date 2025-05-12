FactoryBot.define do
  factory :end_user_transaction do
    association :end_user
    association :client
    sequence(:transaction_identifier) { |n| "txn#{n}" }
    is_foreign { false }
    amount_in_cents { 5000 }
    points_earned { 50 }
  end
end
