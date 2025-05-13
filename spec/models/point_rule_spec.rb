require 'rails_helper'

RSpec.describe PointRule, type: :model do
  include_context "with current client"

  describe 'validations' do
    it { should belong_to(:client) }

    it { should validate_presence_of(:name) }

    context 'when name is not unique' do
      before do
        create(:point_rule, name: 'Test Point Rule')
      end

      it { should validate_uniqueness_of(:name).scoped_to(:client_id) }
    end

    it { should validate_presence_of(:level) }
    it { should validate_numericality_of(:level).only_integer.is_greater_than(0) }

    it { should validate_presence_of(:conditions) }

    it { should validate_presence_of(:actions) }
  end
end
