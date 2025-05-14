class AddWhitelistedIpsToApiKeys < ActiveRecord::Migration[8.0]
  def change
    add_column :api_keys, :whitelisted_ips, :string, array: true, default: []
  end
end
