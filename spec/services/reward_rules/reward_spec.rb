require 'rails_helper'

RSpec.describe RewardRules::Reward do
  include_context 'with current client'

  let(:reward) { described_class.new }
  let(:item_class) { RewardRules::Reward::Item }
  let(:rule) { create(:reward_rule) }

  describe '#add' do
    context 'when adding nil' do
      it 'ignores nil items' do
        reward.add(nil)
        expect(reward.items).to be_empty
      end
    end

    it 'adds an item to the reward' do
      reward.add(item_class.new(name: 'free_coffee', quantity: 2, rule_id: rule.id))
      expect(reward.items.size).to eq(1)
      expect(reward.items.first.name).to eq('free_coffee')
      expect(reward.items.first.quantity).to eq(2)
      expect(reward.items.first.rule_id).to eq(rule.id)
    end

    it 'adds multiple items to the reward' do
      reward.add(item_class.new(name: 'free_coffee', quantity: 2, rule_id: rule.id))
      reward.add(item_class.new(name: 'free_sandwich', quantity: 1, rule_id: rule.id))
      expect(reward.items.size).to eq(2)
      expect(reward.items.map(&:name)).to match_array([ 'free_coffee', 'free_sandwich' ])
      expect(reward.items.map(&:quantity)).to match_array([ 2, 1 ])
      expect(reward.items.map(&:rule_id)).to all(eq(rule.id))
    end
  end

  describe '#items' do
    context 'when no items have been added' do
      it 'returns an empty array' do
        expect(reward.items).to be_empty
      end
    end

    context 'when items have been added' do
      before do
        reward.add(item_class.new(name: 'free_coffee', quantity: 2, rule_id: rule.id))
        reward.add(item_class.new(name: 'free_sandwich', quantity: 1, rule_id: rule.id))
      end

      it 'returns an array of Item objects' do
        expect(reward.items).to all(be_a(item_class))
      end

      it 'returns items with correct names and quantities' do
        items = reward.items
        expect(items.map(&:name)).to contain_exactly('free_coffee', 'free_sandwich')
        expect(items.map(&:quantity)).to contain_exactly(2, 1)
      end
    end
  end
end
