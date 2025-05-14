RSpec.shared_context "with current api key" do
  include_context "with current client"

  let!(:current_api_key) { create(:api_key, client: current_client) }
end
