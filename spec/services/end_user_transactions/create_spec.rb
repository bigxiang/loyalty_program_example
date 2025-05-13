require 'rails_helper'

RSpec.describe EndUserTransactions::Create do
  include_context 'with current client'

  let(:end_user) { create(:end_user) }
  let!(:account) { create(:end_user_account, user: end_user, current_points: 10, total_spent_in_cents: 1000) }
  let(:transaction_identifier) { 'txn-001' }
  let(:is_foreign) { false }
  let(:amount_in_cents) { 10_000 }

  subject(:service_call) do
    described_class.call(
      end_user: end_user,
      transaction_identifier: transaction_identifier,
      is_foreign: is_foreign,
      amount_in_cents: amount_in_cents
    )
  end

  it 'creates a transaction with the given attributes' do
    expect { service_call }.to change(end_user.transactions, :count).by(1)
    transaction = end_user.transactions.last
    expect(transaction.transaction_identifier).to eq(transaction_identifier)
    expect(transaction.is_foreign).to eq(is_foreign)
    expect(transaction.amount_in_cents).to eq(amount_in_cents)
  end

  it 'updates the transaction with points_earned' do
    allow(PointRules::Apply).to receive(:call).and_return(instance_double(PointRules::Point, points: 10))

    transaction = service_call
    expect(transaction.points_earned).to eq(10)
  end

  it 'updates the end user account with new points and total spent' do
    allow(PointRules::Apply).to receive(:call).and_return(instance_double(PointRules::Point, points: 10))

    expect { service_call }.to change { account.reload.current_points }.by(10)
      .and change { account.reload.total_spent_in_cents }.by(amount_in_cents)
  end

  context 'when required attributes are missing' do
    let(:transaction_identifier) { nil }

    it 'raises an error' do
      expect {
        described_class.call(
          end_user: end_user,
          transaction_identifier: transaction_identifier,
          is_foreign: is_foreign,
          amount_in_cents: amount_in_cents
        )
      }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Transaction identifier can't be blank")
    end
  end
end
