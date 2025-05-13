require 'rails_helper'

RSpec.describe '401 Unauthorized', type: :request do
  let(:protected_path) { '/api/v1/points/earn' }

  let(:params) do
    {
      user_identifier: 'user-123',
      birthday: '2000-01-01',
      transaction_identifier: 'txn-001',
      is_foreign: false,
      amount_in_cents: 10_000
    }
  end

  context 'when no authentication is provided' do
    it 'returns 401 Unauthorized' do
      post protected_path, params: params

      expect(response).to have_http_status(:unauthorized)

      json = JSON.parse(response.body)
      expect(json['message'] || json['error']).to match(/unauthorized/i)
    end
  end

  context 'when invalid authentication is provided' do
    it 'returns 401 Unauthorized' do
      post protected_path, params: params, headers: { 'Authorization' => 'Bearer invalidtoken' }

      expect(response).to have_http_status(:unauthorized)

      json = JSON.parse(response.body)
      expect(json['message'] || json['error']).to match(/unauthorized/i)
    end
  end
end
