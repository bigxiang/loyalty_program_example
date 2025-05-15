require 'rails_helper'

RSpec.describe Api::V1::Rewards::Issue do
  include_context 'with current client'

  let(:user) { create(:end_user, birthday: Date.new(2000, Time.current.month, 1)) }
  let(:user_identifier) { user.identifier }
  let(:service) { described_class.new(user_identifier:) }

  before do
    create(:end_user_account, user:, level: 2, total_spent_in_cents: 10_000)
    create(:end_user_transaction, user:, amount_in_cents: 10_000, points_earned: 100)
  end

  describe '#call' do
    context 'when user identifier is missing' do
      let(:user_identifier) { nil }

      it 'returns error' do
        result = service.call

        expect(result).not_to be_success
        expect(result.errors).to include("User identifier can't be blank")
      end
    end

    context 'when user is not found' do
      let(:user_identifier) { 'non_existent' }

      it 'returns error' do
        result = service.call

        expect(result).not_to be_success
        expect(result.errors).to include('User not found')
      end
    end

    context 'when no rewards are applicable' do
      before do
        RewardRule.update_all(active: false)
      end

      it 'returns success with no rewards message' do
        result = service.call

        expect(result).to be_success
        expect(result.data[:message]).to eq('No rewards applicable')
      end
    end

    context 'when rewards are applicable' do
      let!(:rule1) { create(:reward_rule, :free_coffee_level_1) }
      let!(:rule2) { create(:reward_rule, :free_coffee_level_2) }
      let!(:unapplicable_rule) { create(:reward_rule, :free_movie_ticket_level_2) }

      it 'issues rewards and returns success' do
        result = service.call

        expect(result).to be_success
        expect(result.data[:message]).to eq('Rewards issued')
        expect(result.data[:reward_items]).to contain_exactly(
          { name: 'free_coffee', quantity: 1 + 1 }
        )

        # Verify rewards were created with correct transaction identifiers
        rewards = EndUserReward.where(user: user)
        expect(rewards.count).to eq(2)
        expect(rewards.first.issurance_identifier).to eq(
          Digest::MD5.hexdigest("#{user.id}:#{rule1.id}:#{Time.current.beginning_of_day.to_i}")
        )
      end
    end

    context 'with monthly repeat condition' do
      let!(:rule) { create(:reward_rule, :free_coffee_level_1) }

      context 'when reward was issued this month' do
        before do
          create(:end_user_reward,
            user: user,
            reward_rule: rule,
            issued_at: Time.current
          )
        end

        it 'prevents reissuance' do
          result = service.call

          expect(result).to be_success
          expect(result.data[:message]).to eq('No rewards applicable')
        end
      end

      context 'when reward was issued last month' do
        before do
          create(:end_user_reward,
            user: user,
            reward_rule: rule,
            issued_at: 1.month.ago,
            issurance_identifier: Digest::MD5.hexdigest("#{user.id}:#{rule.id}:#{1.month.ago.beginning_of_day.to_i}")
          )
        end

        it 'allows reissuance' do
          result = service.call

          expect(result).to be_success
          expect(result.data[:message]).to eq('Rewards issued')
          expect(EndUserReward.where(user: user).count).to eq(2)
        end
      end
    end

    context 'with yearly repeat condition' do
      let!(:rule) { create(:reward_rule, :free_coffee_level_2) }

      context 'when reward was issued this year' do
        before do
          create(:end_user_reward,
            user: user,
            reward_rule: rule,
            issued_at: Time.current
          )
        end

        it 'prevents reissuance' do
          result = service.call

          expect(result).to be_success
          expect(result.data[:message]).to include('No rewards applicable')
        end
      end

      context 'when reward was issued last year' do
        before do
          create(:end_user_reward,
            user: user,
            reward_rule: rule,
            issued_at: 1.year.ago,
            issurance_identifier: Digest::MD5.hexdigest("#{user.id}:#{rule.id}:#{1.year.ago.beginning_of_day.to_i}")
          )
        end

        it 'allows reissuance' do
          result = service.call

          expect(result).to be_success
          expect(result.data[:message]).to eq('Rewards issued')
          expect(EndUserReward.where(user: user).count).to eq(2)
        end
      end
    end
  end
end
