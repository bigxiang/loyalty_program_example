module RewardRules
  class ApplyRule
    def self.call(rule:, user:)
      new(rule:, user:).call
    end

    def initialize(rule:, user:)
      @rule = rule
      @user = user
    end

    def call
      return nil unless applicable?

      Reward::Item.new(rule_id: rule.id, name: rule.actions["name"], quantity: rule.actions["quantity"])
    end

    private

    attr_reader :rule, :user

    def applicable?
      Applicable.call(rule:, user:)
    end
  end
end
