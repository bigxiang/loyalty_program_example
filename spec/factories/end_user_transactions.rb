FactoryBot.define do
  factory :end_user_transaction do
    association :user, factory: :end_user
    client { Current.client! }
    sequence(:transaction_identifier) { |n| "txn#{n}" }
    is_foreign { false }
    amount_in_cents { 5000 }
    points_earned { 50 }
  end
end
