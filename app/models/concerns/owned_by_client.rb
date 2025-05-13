
module OwnedByClient
  extend ActiveSupport::Concern

  included do
    belongs_to :client

    default_scope { where(client: Current.client!) }
  end
end
