module RewardRules
  class Applicable
    WHITELISTED_ATTRIBUTES = {
      user: [ :monthly_points, :registered_at, :birthday_in_month, :total_spent_in_cents ],
      current: [ :beginning_of_month, :end_of_month, :months_ago ]
    }.freeze

    def self.call(rule:, user:)
      new(rule:, user:).call
    end

    def initialize(rule:, user:)
      @rule = rule
      @user = user
      @client = user.client
    end

    def call
      return false unless rule.active
      return false if rule.level > user.level
      return false if rule.client != client
      return false if issued?

      context_objects = { user: user, current: Time.current }
      Rules::ConditionsChecker.new(rule:, context_objects:, whitelisted_attributes: WHITELISTED_ATTRIBUTES).all_met?
    end

    private

    attr_reader :rule, :user, :client

    def issued?
      last_reward = user.end_user_rewards
        .for_user_and_rule(user.id, rule.id)
        .ordered_by_issued_at
        .first

      return false if last_reward.nil?

      case rule.repeat_condition["type"]
      when "monthly"
        last_reward.issued_at >= Time.current.beginning_of_month
      when "yearly"
        last_reward.issued_at >= Time.current.beginning_of_year
      else
        true # No repeat condition, can only be issued once
      end
    end
  end
end
