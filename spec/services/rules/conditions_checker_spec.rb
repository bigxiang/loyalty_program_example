require 'rails_helper'

RSpec.describe Rules::ConditionsChecker do
  include_context 'with current client'

  let(:checker) { described_class.new(rule: rule, context_objects: context_objects, whitelisted_attributes: whitelisted_attributes) }
  let(:rule) { create(:point_rule, active: true, level: 1, conditions: conditions) }
  let(:conditions) { { transaction: { amount_in_cents: { gte: 100 } } } }
  let(:context_objects) { { transaction: transaction, current: Time.current } }
  let(:transaction) { create(:end_user_transaction, amount_in_cents: 1000) }
  let(:whitelisted_attributes) do
    {
      transaction: [ :amount_in_cents, :is_foreign ],
      user: [ :monthly_points, :registered_at, :birthday, :total_spent_in_cents ],
      current: [ :beginning_of_month, :end_of_month, :months_ago ]
    }
  end

  describe '#all_met?' do
    context 'with basic conditions' do
      context 'when conditions are met' do
        it { expect(checker.all_met?).to eq(true) }
      end

      context 'when conditions are not met' do
        let(:transaction) { create(:end_user_transaction, amount_in_cents: 50) }

        it { expect(checker.all_met?).to eq(false) }
      end
    end

    context 'with multiple conditions' do
      let(:conditions) do
        {
          transaction: {
            amount_in_cents: { gte: 100 },
            is_foreign: { eq: true }
          }
        }
      end
      let(:transaction) { create(:end_user_transaction, amount_in_cents: 1000, is_foreign: true) }

      context 'when all conditions are met' do
        it { expect(checker.all_met?).to eq(true) }
      end

      context 'when some conditions are not met' do
        let(:transaction) { create(:end_user_transaction, amount_in_cents: 1000, is_foreign: false) }

        it { expect(checker.all_met?).to eq(false) }
      end
    end

    context 'with dynamic time conditions' do
      let(:conditions) do
        { user: { registered_at: { gte: "{current.months_ago(2)}" } } }
      end
      let(:context_objects) { { user: user, current: Time.current } }
      let(:user) { create(:end_user, registered_at: 1.month.ago) }

      context 'when time condition is met' do
        it { expect(checker.all_met?).to eq(true) }
      end

      context 'when time condition is not met' do
        let(:user) { create(:end_user, registered_at: 3.months.ago) }

        it { expect(checker.all_met?).to eq(false) }
      end
    end

    context 'with attribute not whitelisted' do
      let(:conditions) { { transaction: { not_whitelisted: { gte: 1 } } } }

      it 'raises NotImplementedError' do
        expect { checker.all_met? }.to raise_error(NotImplementedError, /not_whitelisted/)
      end
    end

    context 'with unknown context' do
      let(:conditions) { { unknown: { monthly_points: { gte: 100 } } } }

      it 'raises NotImplementedError' do
        expect { checker.all_met? }.to raise_error(NotImplementedError, /Unknown context: unknown/)
      end
    end

    context 'with unknown operator' do
      let(:conditions) { { transaction: { amount_in_cents: { unknown: 100 } } } }

      it 'raises NotImplementedError' do
        expect { checker.all_met? }.to raise_error(NotImplementedError, /Operator unknown/)
      end
    end

    context 'with invalid dynamic code' do
      let(:conditions) { { transaction: { amount_in_cents: { gte: '{current.invalid!}' } } } }

      it 'raises NotImplementedError' do
        expect { checker.all_met? }.to raise_error(NotImplementedError, /Attribute invalid! not implemented/)
      end
    end

    context 'with numeric value parsing' do
      let(:conditions) do
        {
          transaction: {
            amount_in_cents: { gte: 100.0 }
          }
        }
      end

      let(:transaction) { create(:end_user_transaction, amount_in_cents: 100) }

      it { expect(checker.all_met?).to eq(true) }
    end
  end
end
