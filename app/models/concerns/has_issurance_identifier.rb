module HasIssuranceIdentifier
  extend ActiveSupport::Concern

  class_methods do
    def generate_issurance_identifier(user_id, rule_id, timestamp = Time.current)
      # Create a consistent identifier based on user and rule
      # This ensures the same user can't get the same reward twice in concurrent requests
      Digest::MD5.hexdigest("#{user_id}:#{rule_id}:#{timestamp.beginning_of_day.to_i}")
    end
  end
end
