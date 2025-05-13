class Current < ActiveSupport::CurrentAttributes
  attribute :client

  class MissingClient < StandardError; end

  def client!
    client || raise(MissingClient, "Client is not set in Current.client")
  end
end
