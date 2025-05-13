require 'rails_helper'

RSpec.describe EndUserAccount, type: :model do
  include_context "with current client"

  describe 'validations' do
    it { should belong_to(:user) }
    it { should belong_to(:client) }

    context 'when user is not unique' do
      before do
        create(:end_user_account)
      end

      it { should validate_uniqueness_of(:user).scoped_to(:client_id) }
    end

    it { should validate_presence_of(:level) }
    it { should validate_numericality_of(:level).only_integer.is_greater_than_or_equal_to(0) }

    it { should validate_presence_of(:current_points) }
    it { should validate_numericality_of(:current_points).only_integer.is_greater_than_or_equal_to(0) }

    it { should validate_presence_of(:total_spent_in_cents) }
    it { should validate_numericality_of(:total_spent_in_cents).only_integer.is_greater_than_or_equal_to(0) }
  end

  describe '#monthly_points' do
    let(:end_user) { create(:end_user) }
    let(:account) { create(:end_user_account, user: end_user) }

    before do
      # This month
      create(:end_user_transaction, user: end_user, points_earned: 10, created_at: Time.zone.now.beginning_of_month + 1.day)
      create(:end_user_transaction, user: end_user, points_earned: 20, created_at: Time.zone.now.end_of_month - 1.day)
      # Last month
      create(:end_user_transaction, user: end_user, points_earned: 30, created_at: 1.month.ago.beginning_of_month + 1.day)
    end

    it 'returns the sum of points_earned for transactions in the current month by default' do
      expect(account.monthly_points).to eq(30)
    end

    it 'returns the sum for a given month if specified' do
      last_month = 1.month.ago
      expect(account.monthly_points(last_month)).to eq(30)
    end
  end
end
