require 'rails_helper'

RSpec.describe 'Api::V1::Points', type: :request do
  include_context "with current api key"

  describe 'POST /api/v1/points/earn' do
    let(:params) do
      {
        user_identifier: 'user-123',
        birthday: '2000-01-01',
        transaction_identifier: 'txn-001',
        is_foreign: false,
        amount_in_cents: 10_000
      }
    end

    context 'with valid parameters' do
      it 'returns success and the correct response' do
        post '/api/v1/points/earn', params: params, headers: { "Authorization" => "Bearer #{current_api_key.token}" }

        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json['message']).to eq(I18n.t('api.v1.points.earn.success'))
        expect(json['data']).to include('points_earned', 'current_points', 'monthly_points')
      end
    end

    context 'with missing required parameters' do
      it 'returns an error and unprocessable_entity status' do
        post '/api/v1/points/earn', params: params.except(:user_identifier), headers: { "Authorization" => "Bearer #{current_api_key.token}" }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['message']).to eq(I18n.t('api.v1.points.earn.error'))
        expect(json['errors']).to include("User identifier can't be blank")
      end
    end

    context 'when the service returns an error' do
      let(:earn_service) { instance_double(Api::V1::Points::Earn, invalid?: false) }

      before do
        allow(Api::V1::Points::Earn).to receive(:new).and_return(earn_service)
        allow(earn_service).to receive(:call).and_return(
          Api::V1::Result.new(success: false, errors: [ 'Something went wrong' ])
        )
      end

      it 'returns an error and unprocessable_entity status' do
        post '/api/v1/points/earn', params: params, headers: { "Authorization" => "Bearer #{current_api_key.token}" }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['message']).to eq(I18n.t('api.v1.points.earn.error'))
        expect(json['errors']).to include('Something went wrong')
      end
    end
  end
end
