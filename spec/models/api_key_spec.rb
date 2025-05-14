require 'rails_helper'

RSpec.describe ApiKey, type: :model do
  include_context "with current client"

  describe ".active" do
    let!(:active_key) { create(:api_key, expires_at: 1.day.from_now) }
    let!(:never_expires_key) { create(:api_key, expires_at: nil) }
    let!(:expired_key) { create(:api_key, expires_at: 1.day.ago) }
    let!(:revoked_key) { create(:api_key, revoked_at: 1.day.ago) }

    it "returns keys that are not expired or revoked" do
      expect(ApiKey.active).to include(active_key, never_expires_key)
      expect(ApiKey.active).not_to include(expired_key, revoked_key)
    end
  end

  describe ".token_digest" do
    it "returns a HMAC digest of the token" do
      token = "sometoken"
      digest = ApiKey.token_digest(token)
      expected = OpenSSL::HMAC.hexdigest("SHA256", "example_secret_key", token)
      expect(digest).to eq(expected)
    end
  end

  describe ".authenticate" do
    let!(:api_key) { create(:api_key, expires_at: 1.day.from_now, whitelisted_ips: [ "1.2.3.4" ]) }

    it "returns the api_key when given a valid token and whitelisted ip" do
      found = ApiKey.authenticate(api_key.token, "1.2.3.4")
      expect(found).to eq(api_key)
    end

    it "returns nil for a valid token but non-whitelisted ip" do
      found = ApiKey.authenticate(api_key.token, "5.6.7.8")
      expect(found).to be_nil
    end

    it "returns the api_key if whitelisted_ips is blank" do
      api_key = create(:api_key, expires_at: 1.day.from_now, whitelisted_ips: [])
      found = ApiKey.authenticate(api_key.token, "5.6.7.8")
      expect(found).to eq(api_key)
    end
  end

  describe "#ip_allowed?" do
    let(:api_key) { build(:api_key, whitelisted_ips: [ "1.2.3.4" ]) }

    it "returns true if whitelisted_ips is blank" do
      api_key.whitelisted_ips = []
      expect(api_key.ip_allowed?("5.6.7.8")).to be true
    end

    it "returns true if ip is in the whitelist" do
      expect(api_key.ip_allowed?("1.2.3.4")).to be true
    end

    it "returns false if ip is not in the whitelist" do
      expect(api_key.ip_allowed?("5.6.7.8")).to be false
    end
  end

  describe "token generation" do
    it "generates a token and token_digest before validation on create" do
      api_key = build(:api_key)
      expect(api_key.token).to be_nil
      expect(api_key.token_digest).to be_nil

      api_key.valid?

      expect(api_key.token).to be_present
      expect(api_key.token_digest).to be_present
    end
  end
end
