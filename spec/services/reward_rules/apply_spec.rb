require 'rails_helper'

RSpec.describe RewardRules::Apply do
  include_context 'with current client'

  let(:user) { create(:end_user) }

  let!(:rule1) { create(:reward_rule, active: true, level: 1, conditions: { user: { total_spent_in_cents: { gte: 100 } } }) }
  let!(:rule2) { create(:reward_rule, active: true, level: 1, conditions: { user: { total_spent_in_cents: { gte: 200 } } }) }
  let!(:rule3) { create(:reward_rule, active: true, level: 2, conditions: { user: { total_spent_in_cents: { gte: 300 } } }) }
  let!(:rule4) { create(:reward_rule, active: false, level: 1, conditions: { user: { total_spent_in_cents: { gte: 100 } } }) }

  before do
    create(:end_user_account, user: user, level: 1, total_spent_in_cents: 400)
  end

  subject { described_class.new(user: user) }

  describe '#call' do
    context 'when no rules are applicable' do
      before do
        RewardRule.update_all(active: false)
      end

      it 'returns an empty reward' do
        result = subject.call

        expect(result).to be_a(RewardRules::Reward)
        expect(result.items).to be_empty
      end
    end

    context 'when some rules are applicable' do
      before do
        rule1.update!(actions: { 'name' => 'free_coffee', 'quantity' => 1 })
        rule2.update!(actions: { 'name' => 'free_sandwich', 'quantity' => 2 })
      end

      it 'returns a reward with applicable items' do
        result = subject.call
        expect(result).to be_a(RewardRules::Reward)
        expect(result.items.size).to eq(2)
        expect(result.items.map(&:name)).to match_array([ 'free_coffee', 'free_sandwich' ])
        expect(result.items.map(&:quantity)).to match_array([ 1, 2 ])
      end
    end
  end
end
