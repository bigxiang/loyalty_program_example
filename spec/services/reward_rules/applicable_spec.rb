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

    context 'with dynamic current time condition' do
      let(:conditions) do
        { user: { registered_at: { gte: "{current.months_ago(2)}" } } }
      end

      before do
        user.update!(registered_at: Time.current - 1.month)
      end

      it { expect(subject.call).to eq(true) }

      context 'when registered_at is earlier than 2 months ago' do
        before { user.update!(registered_at: Time.current - 3.months) }

        it { expect(subject.call).to eq(false) }
      end
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

    context 'with attribute not whitelisted' do
      let(:conditions) { { user: { not_whitelisted: { gte: 1 } } } }

      it 'raises NotImplementedError' do
        expect { subject.call }.to raise_error(NotImplementedError, /not_whitelisted/)
      end
    end

    context 'with unknown context' do
      let(:conditions) { { unknown: { monthly_points: { gte: 100 } } } }

      it { expect(subject.call).to eq(false) }
    end

    context 'with unknown operator' do
      let(:conditions) { { user: { monthly_points: { unknown: 100 } } } }

      it 'raises NotImplementedError' do
        expect { subject.call }.to raise_error(NotImplementedError, /Operator unknown/)
      end
    end

    context 'with invalid attribute' do
      let(:conditions) { { user: { monthly_points: { gte: '{current.invalid!}' } } } }

      it 'raises NotImplementedError' do
        expect { subject.call }.to raise_error(NotImplementedError, /Attribute invalid! not implemented/)
      end
    end

    context 'with float argument parsing' do
      let(:rule) do
        create(:reward_rule,
          active: true,
          level: 1,
          conditions: {
            user: {
              monthly_points: { gte: 100.0 },
              total_spent_in_cents: { gte: 200_000 }
            }
          }
        )
      end

      it { expect(subject.call).to eq(false) }
    end
  end
end
