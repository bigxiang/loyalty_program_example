class Current < ActiveSupport::CurrentAttributes
  attribute :client

  class MissingClient < StandardError; end

  def client!
    client || raise(MissingClient, "Client is not set in Current.client")
  end

  def with_client(client)
    current_client = self.client
    self.client = client
    yield
  ensure
    self.client = current_client
  end
end
