require 'rails_helper'

RSpec.describe HasIssuranceIdentifier do
  let(:dummy_class) do
    Class.new do
      include HasIssuranceIdentifier
    end
  end

  describe '.generate_issurance_identifier' do
    let(:user_id) { 1 }
    let(:rule_id) { 2 }
    let(:timestamp) { Time.new(2024, 1, 1, 12, 0, 0) }

    it 'generates consistent identifiers for same inputs' do
      identifier1 = dummy_class.generate_issurance_identifier(user_id, rule_id, timestamp)
      identifier2 = dummy_class.generate_issurance_identifier(user_id, rule_id, 1.second.since(timestamp))
      expect(identifier1).to eq(identifier2)
    end

    it 'generates different identifiers for different users' do
      identifier1 = dummy_class.generate_issurance_identifier(1, rule_id, timestamp)
      identifier2 = dummy_class.generate_issurance_identifier(2, rule_id, timestamp)
      expect(identifier1).not_to eq(identifier2)
    end

    it 'generates different identifiers for different rules' do
      identifier1 = dummy_class.generate_issurance_identifier(user_id, 1, timestamp)
      identifier2 = dummy_class.generate_issurance_identifier(user_id, 2, timestamp)
      expect(identifier1).not_to eq(identifier2)
    end

    it 'generates different identifiers for different days' do
      identifier1 = dummy_class.generate_issurance_identifier(user_id, rule_id, timestamp)
      identifier2 = dummy_class.generate_issurance_identifier(user_id, rule_id, timestamp + 1.day)
      expect(identifier1).not_to eq(identifier2)
    end
  end
end
