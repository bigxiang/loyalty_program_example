require 'rails_helper'

RSpec.describe 'Api::V1::Points', type: :request do
  describe 'POST /api/v1/points/earn' do
    context 'with valid parameters' do
      it 'returns success and the correct response' do
        post '/api/v1/points/earn'

        expect(response).to have_http_status(:ok)

        expect(JSON.parse(response.body)).to include(
          'message' => 'Points earned successfully'
        )
      end
    end
  end
end
