require 'rails_helper'

RSpec.describe Api::V1::Points::Earn do
  include_context 'with current client'

  let(:user_identifier) { 'user-123' }
  let(:birthday) { Date.new(2000, 1, 1) }
  let(:transaction_identifier) { 'txn-001' }
  let(:is_foreign) { false }
  let(:amount_in_cents) { 10_000 }

  let(:service) do
    described_class.new(
      user_identifier: user_identifier,
      birthday: birthday,
      transaction_identifier: transaction_identifier,
      is_foreign: is_foreign,
      amount_in_cents: amount_in_cents
    )
  end

  subject(:result) { service.call }

  describe '#call' do
    context 'when all attributes are valid and user exists' do
      let!(:end_user) { create(:end_user, identifier: user_identifier, birthday: birthday) }
      let!(:account) { create(:end_user_account, end_user: end_user) }

      it 'creates a transaction and returns points data' do
        expect { result }.to change { EndUserTransaction.count }.by(1)

        expect(result).to be_success

        expect(result.data[:points_earned]).to be_a(Integer)
        expect(result.data[:current_points]).to be_a(Integer)
        expect(result.data[:monthly_points]).to be_a(Integer)
      end
    end

    context 'when all attributes are valid and user does not exist' do
      it 'creates a user, a transaction, and returns points data' do
        expect { result }.to change { EndUserTransaction.count }.by(1)
          .and change { EndUser.count }.by(1)
          .and change { EndUserAccount.count }.by(1)

        expect(result).to be_success

        expect(result.data[:points_earned]).to be_a(Integer)
        expect(result.data[:current_points]).to be_a(Integer)
        expect(result.data[:monthly_points]).to be_a(Integer)
      end
    end

    context 'when attributes are invalid' do
      let(:user_identifier) { nil }

      it 'returns a failed result with error messages' do
        expect(result).not_to be_success

        expect(result.errors).to include("User identifier can't be blank")
      end
    end
  end
end
