RSpec.shared_context "with current client" do
  let(:current_client) { create(:client) }

  before do
    Current.client = current_client
  end
end
