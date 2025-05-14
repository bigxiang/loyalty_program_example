require 'factory_bot_rails'
include FactoryBot::Syntax::Methods

client = Client.find_or_create_by!(name: "Client 1")
Current.with_client(client) do
  api_key = create(:api_key)

  puts "=" * 80
  puts "API Key: #{api_key.token}"
  puts "=" * 80

  create(:point_rule, :point_earning_level_1)
  create(:point_rule, :point_earning_level_2)

  end_user1 = create(:end_user, identifier: "user-001", birthday: "2000-1-1")
  create(:end_user_account, user: end_user1, level: 1)

  end_user2 = create(:end_user, identifier: "user-002", birthday: "2000-1-1")
  create(:end_user_account, user: end_user2, level: 2)
end
