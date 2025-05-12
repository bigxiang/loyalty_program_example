require 'rails_helper'

RSpec.describe '404 Not Found', type: :request do
  it 'returns 404 not found for a non-existent route' do
    get '/api/v1/nonexistent'
    expect(response).to have_http_status(:not_found)
    expect(JSON.parse(response.body)).to include('error' => 'Resource not found')
  end
end
