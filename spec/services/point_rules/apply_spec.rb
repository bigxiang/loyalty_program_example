require 'rails_helper'

RSpec.describe PointRules::Apply do
  include_context 'with current client'

  let(:end_user) { create(:end_user) }
  let(:transaction) do
    create(:end_user_transaction, end_user: end_user, amount_in_cents: amount_in_cents, is_foreign: is_foreign)
  end
  let(:amount_in_cents) { 10_000 }
  let(:is_foreign) { false }
  let(:user_level) { 2 }

  before do
    create(:end_user_account, user: end_user, level: user_level)
  end

  subject(:result_point) { described_class.call(transaction: transaction) }

  context 'when there are multiple applicable rules' do
    let(:is_foreign) { true }

    let!(:rule1) { create(:point_rule, :point_earning_level_1) }
    let!(:rule2) { create(:point_rule, :point_earning_level_2) }

    it 'returns the sum of all applicable points and multipliers' do
      expect(result_point.base_points).to eq(10) # from rule1
      expect(result_point.multiplier).to eq(1)   # from rule2
      expect(result_point.points).to eq(20)      # 10 * (1 + 1)
    end
  end

  context 'when there are no applicable rules' do
    it 'returns a zero point object' do
      expect(result_point.base_points).to eq(0)
      expect(result_point.multiplier).to eq(0)
      expect(result_point.points).to eq(0)
    end
  end

  context 'when only one rule applies' do
    let(:user_level) { 1 }
    let(:is_foreign) { false }

    let!(:rule1) { create(:point_rule, :point_earning_level_1) }

    it 'returns the points from the applicable rule' do
      expect(result_point.base_points).to eq(10)
      expect(result_point.multiplier).to eq(0)
      expect(result_point.points).to eq(10)
    end
  end

  context 'when rules have only multipliers' do
    let(:is_foreign) { true }

    let!(:rule) do
      create(:point_rule, level: 2, conditions: { transaction: { is_foreign: { eq: true } } }, actions: { "multiplier" => 2 })
    end

    it 'returns the correct multiplier' do
      expect(result_point.base_points).to eq(0)
      expect(result_point.multiplier).to eq(2)
      expect(result_point.points).to eq(0)
    end
  end
end
