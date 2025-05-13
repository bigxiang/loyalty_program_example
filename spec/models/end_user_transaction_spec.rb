require 'rails_helper'

RSpec.describe EndUserTransaction, type: :model do
  include_context "with current client"

  it { should belong_to(:end_user) }
  it { should belong_to(:client) }

  it { should validate_presence_of(:transaction_identifier) }

  context 'when transaction_identifier is not unique' do
    before do
      create(:end_user_transaction)
    end

    it { should validate_uniqueness_of(:transaction_identifier).scoped_to(:client_id) }
  end

  it { should validate_presence_of(:amount_in_cents) }
  it { should validate_numericality_of(:amount_in_cents).only_integer.is_greater_than_or_equal_to(0) }

  it { should validate_presence_of(:points_earned) }
  it { should validate_numericality_of(:points_earned).only_integer.is_greater_than_or_equal_to(0) }

  describe '#available_point_rules' do
    let(:end_user) { create(:end_user) }
    let(:transaction) { create(:end_user_transaction, end_user: end_user) }
    let(:user_level) { 1 }

    let!(:rule1) { create(:point_rule, :point_earning_level_1) }
    let!(:rule2) { create(:point_rule, :point_earning_level_2) }
    let!(:rule3) { create(:point_rule, :point_earning_level_1, name: 'Inactive Rule', active: false) }

    before do
      create(:end_user_account, end_user: end_user, level: user_level)
    end

    it 'returns only active rules with level <= end_user.level' do
      expect(transaction.available_point_rules).to include(rule1)

      expect(transaction.available_point_rules).not_to include(rule2)
      expect(transaction.available_point_rules).not_to include(rule3)
    end

    context 'when end_user.level is higher' do
      let(:user_level) { 2 }

      it 'includes higher level rules' do
        expect(transaction.available_point_rules).to include(rule1, rule2)
      end
    end
  end
end
