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
    let!(:api_key) { create(:api_key, expires_at: 1.day.from_now) }

    it "returns the api_key when given a valid token" do
      found = ApiKey.authenticate(api_key.token)
      expect(found).to eq(api_key)
    end

    it "returns nil for an invalid token" do
      expect(ApiKey.authenticate("invalidtoken")).to be_nil
    end

    it "returns nil for an expired key" do
      expired_key = create(:api_key, expires_at: 1.day.ago)
      expect(ApiKey.authenticate(expired_key.token)).to be_nil
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
