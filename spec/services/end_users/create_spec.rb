require 'rails_helper'

RSpec.describe EndUsers::Create do
  include_context 'with current client'

  let(:identifier) { 'user-123' }
  let(:birthday) { Date.new(2000, 1, 1) }
  let(:registered_at) { Time.zone.now }

  subject(:service_call) { described_class.call(identifier: identifier, birthday: birthday, registered_at: registered_at) }

  it 'creates an EndUser with the given attributes' do
    expect { service_call }.to change(EndUser, :count).by(1)

    end_user = EndUser.last

    expect(end_user.identifier).to eq(identifier)
    expect(end_user.birthday).to eq(birthday)
    expect(end_user.registered_at.to_i).to eq(registered_at.to_i)
  end

  it 'creates an associated EndUserAccount with default values' do
    expect { service_call }.to change(EndUserAccount, :count).by(1)

    end_user = EndUser.last
    account = end_user.account

    expect(account.level).to eq(EndUser::MIN_LEVEL)
    expect(account.current_points).to eq(0)
    expect(account.total_spent_in_cents).to eq(0)
  end

  context 'when required attributes are missing' do
    let(:identifier) { nil }
    let(:birthday) { nil }

    it 'raises an error' do
      expect { service_call }.to raise_error(
        ActiveRecord::RecordInvalid,
        "Validation failed: Identifier can't be blank, Birthday can't be blank"
      )
    end
  end
end
