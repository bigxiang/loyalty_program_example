require 'rails_helper'

RSpec.describe RewardRules::ApplyRule do
  include_context 'with current client'

  let(:user) { create(:end_user) }
  let(:rule) { create(:reward_rule, actions: { 'name' => 'free_coffee', 'quantity' => 2 }) }

  let(:service) { described_class.new(rule: rule, user: user) }

  subject(:result) { service.call }

  describe '#call' do
    it 'returns a Reward with rule_id if applicable' do
      expect(RewardRules::Applicable).to receive(:call).with(rule: rule, user: user).and_return(true)

      expect(result.rule_id).to eq(rule.id)
      expect(result.name).to eq('free_coffee')
      expect(result.quantity).to eq(2)
    end

    it 'returns nil if not applicable' do
      expect(RewardRules::Applicable).to receive(:call).with(rule: rule, user: user).and_return(false)

      expect(result).to be_nil
    end
  end
end
