require 'rails_helper'

RSpec.describe '500 Internal Server Error', type: :request do
  include_context "with current client"

  # We'll define a temporary route and controller for testing 500 errors
  before(:all) do
    Rails.application.routes.clear!
    Rails.application.routes.draw do
      get '/api/v1/trigger_500', to: 'api/v1/errors#trigger_500'
    end
  end

  after(:all) do
    Rails.application.reload_routes!
  end

  # Define a stub controller for this test
  before do
    class Api::V1::ErrorsController < ApplicationController
      def trigger_500
        raise "Simulated server error"
      end
    end
  end

  it 'returns 500 internal server error for an unhandled exception' do
    get '/api/v1/trigger_500', headers: { "X-Client-Id" => current_client.id }

    expect(response).to have_http_status(:internal_server_error)
    expect(JSON.parse(response.body)).to include('error' => 'Internal server error')
  end
end
