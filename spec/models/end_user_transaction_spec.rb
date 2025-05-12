require 'rails_helper'

RSpec.describe EndUserTransaction, type: :model do
  it { should belong_to(:end_user) }
  it { should belong_to(:client) }

  it { should validate_presence_of(:transaction_identifier) }

  context 'when transaction_identifier is not unique' do
    before do
      create(:end_user_transaction)
    end

    it { should validate_uniqueness_of(:transaction_identifier).scoped_to(:client_id) }
  end

  it { should validate_presence_of(:end_user) }

  it { should validate_presence_of(:amount_in_cents) }
  it { should validate_numericality_of(:amount_in_cents).only_integer.is_greater_than_or_equal_to(0) }

  it { should validate_presence_of(:points_earned) }
  it { should validate_numericality_of(:points_earned).only_integer.is_greater_than_or_equal_to(0) }
end
