require 'rails_helper'

RSpec.describe RewardRules::Applicable do
  include_context 'with current client'

  let(:user) { create(:end_user) }
  let(:rule) { create(:reward_rule, active: true, level: 1, conditions: conditions) }

  before do
    create(:end_user_account, user: user, level: 1, total_spent_in_cents: 100_000)
  end

  subject { described_class.new(rule: rule, user: user) }

  describe '#call' do
    let(:conditions) { { user: { total_spent_in_cents: { gte: 100 } } } }

    context 'when rule is inactive' do
      before { rule.update!(active: false) }

      it { expect(subject.call).to eq(false) }
    end

    context 'when user level is too low' do
      before { user.account.update!(level: 0) }

      it { expect(subject.call).to eq(false) }
    end

    context 'when client does not match' do
      before { rule.update!(client: create(:client)) }

      it { expect(subject.call).to eq(false) }
    end

    context 'with repeat conditions' do
      context 'when rule is monthly' do
        before { rule.update!(repeat_condition: { type: 'monthly' }) }

        context 'when no rewards have been issued' do
          it { expect(subject.call).to eq(true) }
        end

        context 'when reward was issued this month' do
          before do
            create(:end_user_reward, user: user, reward_rule: rule, issued_at: Time.current)
          end

          it { expect(subject.call).to eq(false) }
        end

        context 'when reward was issued last month' do
          before do
            create(:end_user_reward, user: user, reward_rule: rule, issued_at: 1.month.ago)
          end

          it { expect(subject.call).to eq(true) }
        end
      end

      context 'when rule is yearly' do
        before { rule.update!(repeat_condition: { type: 'yearly' }) }

        context 'when no rewards have been issued' do
          it { expect(subject.call).to eq(true) }
        end

        context 'when reward was issued this year' do
          before do
            create(:end_user_reward, user: user, reward_rule: rule, issued_at: Time.current)
          end

          it { expect(subject.call).to eq(false) }
        end

        context 'when reward was issued last year' do
          before do
            create(:end_user_reward, user: user, reward_rule: rule, issued_at: 1.year.ago)
          end

          it { expect(subject.call).to eq(true) }
        end
      end
    end

    context 'when all conditions under a rule are met' do
    let(:conditions_checker) { instance_double(Rules::ConditionsChecker, all_met?: true) }

    before do
      allow(Rules::ConditionsChecker).to receive(:new).and_return(conditions_checker)
    end

    it 'returns true' do
      expect(subject.call).to eq(true)
    end
  end

  context 'when any condition under a rule is not met' do
    let(:conditions_checker) { instance_double(Rules::ConditionsChecker, all_met?: false) }

    before do
      allow(Rules::ConditionsChecker).to receive(:new).and_return(conditions_checker)
    end

    it 'returns false' do
      expect(subject.call).to eq(false)
    end
  end
  end
end
