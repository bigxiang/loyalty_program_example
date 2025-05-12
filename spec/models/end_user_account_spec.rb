require 'rails_helper'

RSpec.describe EndUserAccount, type: :model do
  describe 'validations' do
    it { should belong_to(:end_user) }
    it { should belong_to(:client) }

    it { should validate_presence_of(:end_user) }

    context 'when end_user is not unique' do
      before do
        create(:end_user_account)
      end

      it { should validate_uniqueness_of(:end_user).scoped_to(:client_id) }
    end

    it { should validate_presence_of(:level) }
    it { should validate_numericality_of(:level).only_integer.is_greater_than_or_equal_to(0) }

    it { should validate_presence_of(:current_points) }
    it { should validate_numericality_of(:current_points).only_integer.is_greater_than_or_equal_to(0) }

    it { should validate_presence_of(:monthly_points) }
    it { should validate_numericality_of(:monthly_points).only_integer.is_greater_than_or_equal_to(0) }

    it { should validate_presence_of(:total_spent_in_cents) }
    it { should validate_numericality_of(:total_spent_in_cents).only_integer.is_greater_than_or_equal_to(0) }
  end
end
