require 'rails_helper'

RSpec.describe "Api::V1::Rewards", type: :request do
  include_context 'with current api key'

  describe "POST /api/v1/rewards/issue" do
    let(:user) { create(:end_user, birthday: Date.new(2000, Time.current.month, 1)) }
    let(:params) do
      {
        user_identifier: user.identifier
      }
    end

    before do
      create(:end_user_account, user:, level: 2, total_spent_in_cents: 10_000)
      create(:end_user_transaction, user:, amount_in_cents: 10_000, points_earned: 100)
    end

    context 'when user exists and has applicable rewards' do
      let!(:rule) { create(:reward_rule, :free_coffee_level_1) }

      it 'returns success with reward data' do
        post "/api/v1/rewards/issue", params: params, headers: { "Authorization" => "Bearer #{current_api_key.token}" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['message']).to eq(I18n.t('api.v1.rewards.issue.success'))
        expect(json['data']).to have_key('reward_items')
      end
    end

    context 'when user does not exist' do
      let(:params) do
        {
          user_identifier: 'non_existent_user'
        }
      end

      it 'returns error' do
        post "/api/v1/rewards/issue", params: params, headers: { "Authorization" => "Bearer #{current_api_key.token}" }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['message']).to eq(I18n.t('api.v1.rewards.issue.error'))
        expect(json['errors']).to include('User not found')
      end
    end

    context 'when user has no applicable rewards' do
      it 'returns success with no rewards message' do
        post "/api/v1/rewards/issue", params: params, headers: { "Authorization" => "Bearer #{current_api_key.token}" }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['message']).to eq(I18n.t('api.v1.rewards.issue.error'))
        expect(json['errors']).to include('No rewards applicable')
      end
    end

    context 'when rewards have already been issued' do
      let!(:rule) { create(:reward_rule, :free_coffee_level_1) }
      let!(:reward) { create(:end_user_reward, user: user, reward_rule: rule) }

      it 'returns error for duplicate issuance' do
        post "/api/v1/rewards/issue", params: params, headers: { "Authorization" => "Bearer #{current_api_key.token}" }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['message']).to eq(I18n.t('api.v1.rewards.issue.error'))
        expect(json['errors']).to include('No rewards applicable')
      end
    end
  end
end
