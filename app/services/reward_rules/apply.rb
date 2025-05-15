module RewardRules
  class Apply
    def self.call(user:)
      new(user:).call
    end

    def initialize(user:)
      @user = user
    end

    def call
      RewardRule.active.available_for(user).each_with_object(Reward.new) do |rule, reward|
        reward.add(ApplyRule.call(rule:, user:))
      end
    end

    private

    attr_reader :user
  end
end
