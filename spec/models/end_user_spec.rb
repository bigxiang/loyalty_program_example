require 'rails_helper'

RSpec.describe EndUser, type: :model do
  include_context "with current client"

  describe 'validations' do
    it { should belong_to(:client) }

    it { should validate_presence_of(:identifier) }

    context 'when identifier is not unique' do
      before do
        create(:end_user)
      end

      it { should validate_uniqueness_of(:identifier).scoped_to(:client_id) }
    end

    it { should validate_presence_of(:birthday) }

    it { should validate_presence_of(:registered_at) }
  end
end
