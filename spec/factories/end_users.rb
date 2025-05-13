FactoryBot.define do
  factory :end_user do
    client { Current.client! }
    sequence(:identifier) { |n| "user#{n}" }
    birthday { Date.new(1990, 1, 1) }
    registered_at { Time.current }
  end
end
