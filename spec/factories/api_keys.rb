FactoryBot.define do
  factory :api_key do
    client { Current.client! }
  end
end
