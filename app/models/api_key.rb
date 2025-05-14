class ApiKey < ApplicationRecord
  include OwnedByClient

  # TODO: move to credentials in the real app, it's just for the example.
  HMAC_SECRET_KEY = "example_secret_key"

  # The token is not stored in the database, we will only know the value once after creation.
  attr_accessor :token

  validates :token_digest, presence: true, uniqueness: true

  scope :active, -> { where(revoked_at: nil).where(expires_at: nil).or(where("expires_at > ?", Time.current)) }

  before_validation :generate_token, on: :create

  def self.authenticate(token, ip)
    # We need to use unscoped here because we don't know the client before the authentication.
    # Although we can pass client information in the request headers or use subdomains, but we don't
    # need to do that in this example.
    api_key = unscoped.active.find_by(token_digest: token_digest(token))
    return nil unless api_key&.ip_allowed?(ip)

    api_key
  end

  def self.token_digest(token)
    OpenSSL::HMAC.hexdigest("SHA256", HMAC_SECRET_KEY, token)
  end

  def ip_allowed?(ip)
    whitelisted_ips.blank? || whitelisted_ips.include?(ip)
  end

  private

  def generate_token
    self.token = SecureRandom.base58(24)
    self.token_digest = self.class.token_digest(token)
  end
end
