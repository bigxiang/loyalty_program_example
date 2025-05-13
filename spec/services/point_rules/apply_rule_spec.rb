require 'rails_helper'

RSpec.describe PointRules::ApplyRule do
  include_context 'with current client'

  let(:end_user) { create(:end_user) }
  let(:transaction) do
    create(:end_user_transaction, end_user: end_user, amount_in_cents: amount_in_cents, is_foreign: is_foreign)
  end
  let(:amount_in_cents) { 10_000 }
  let(:is_foreign) { false }
  let(:user_level) { 1 }

  before do
    create(:end_user_account, user: end_user, level: user_level)
  end

  subject(:result_point) { described_class.call(rule: rule, transaction: transaction) }

  context 'with a points-per-amount rule' do
    let(:rule) { create(:point_rule, :point_earning_level_1) }
    it 'returns the correct base points' do
      expect(result_point.base_points).to eq(10)
      expect(result_point.multiplier).to eq(0)
      expect(result_point.points).to eq(10)
    end

    context 'when amount is not divisible by per' do
      let(:amount_in_cents) { 21_000 }

      it 'does not round up' do
        expect(result_point.base_points).to eq(20)
      end
    end
  end

  context 'with a multiplier rule' do
    let(:rule) { create(:point_rule, :point_earning_level_2) }
    let(:user_level) { 2 }
    let(:is_foreign) { true }
    it 'returns the correct multiplier' do
      expect(result_point.base_points).to eq(0)
      expect(result_point.multiplier).to eq(1)
      expect(result_point.points).to eq(0)
    end
  end

  context 'with a fixed points rule' do
    let(:rule) do
      create(:point_rule, :point_earning_level_1, actions: { "points" => 5 })
    end
    it 'returns the correct base points' do
      expect(result_point.base_points).to eq(5)
      expect(result_point.multiplier).to eq(0)
      expect(result_point.points).to eq(5)
    end
  end

  context 'when rule is not applicable' do
    let(:rule) { create(:point_rule, :point_earning_level_1) }

    before do
      allow(PointRules::Applicable).to receive(:call).and_return(false)
    end

    it 'returns a zero point object' do
      expect(result_point.base_points).to eq(0)
      expect(result_point.multiplier).to eq(0)
      expect(result_point.points).to eq(0)
    end
  end
end
