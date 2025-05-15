require 'rails_helper'

RSpec.describe PointRules::Applicable do
  include_context 'with current client'

  let(:end_user) { create(:end_user) }
  let(:transaction) do
    create(
      :end_user_transaction,
      user: end_user,
      amount_in_cents: amount_in_cents,
      is_foreign: is_foreign
    )
  end
  let(:amount_in_cents) { 10_000 }
  let(:is_foreign) { false }

  let(:rule) do
    create(:point_rule, :point_earning_level_1)
  end
  let(:user_level) { 1 }

  before do
    create(:end_user_account, user: end_user, level: user_level)
  end

  subject(:applicable) { described_class.call(rule: rule, transaction: transaction) }

  context 'when rule is active, user level is sufficient, client matches, and conditions are met' do
    it 'returns true' do
      expect(applicable).to eq(true)
    end
  end

  context 'when rule is inactive' do
    before { rule.update!(active: false) }

    it 'returns false' do
      expect(applicable).to eq(false)
    end
  end

  context 'when user level is too low' do
    let(:user_level) { 0 }

    it 'returns false' do
      expect(applicable).to eq(false)
    end
  end

  context 'when rule client does not match transaction client' do
    before { rule.update!(client: create(:client)) }

    it 'returns false' do
      expect(applicable).to eq(false)
    end
  end

  context 'when all conditions under a rule are met' do
    let(:conditions_checker) { instance_double(Rules::ConditionsChecker, all_met?: true) }

    before do
      allow(Rules::ConditionsChecker).to receive(:new).and_return(conditions_checker)
    end

    it 'returns true' do
      expect(applicable).to eq(true)
    end
  end

  context 'when any condition under a rule is not met' do
    let(:conditions_checker) { instance_double(Rules::ConditionsChecker, all_met?: false) }

    before do
      allow(Rules::ConditionsChecker).to receive(:new).and_return(conditions_checker)
    end

    it 'returns false' do
      expect(applicable).to eq(false)
    end
  end
end
