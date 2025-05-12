require 'rails_helper'

RSpec.describe Client, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }

    context 'when name is not unique' do
      before do
        create(:client, name: 'Test Client')
      end

      it { should validate_uniqueness_of(:name) }
    end
  end
end
