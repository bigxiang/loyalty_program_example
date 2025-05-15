
module PointRules
  class Applicable
    WHITELISTED_ATTRIBUTES = {
      transaction: [ :amount_in_cents, :is_foreign ]
    }.freeze

    def self.call(rule:, transaction:)
      new(rule:, transaction:).call
    end

    def initialize(rule:, transaction:)
      @rule = rule
      @transaction = transaction
      @user = transaction.user
      @client = transaction.client
    end

    def call
      return false unless rule.active
      return false if rule.level > user.level
      return false if rule.client != client

      context_objects = { user:, transaction: }
      Rules::ConditionsChecker.new(rule:, context_objects:, whitelisted_attributes: WHITELISTED_ATTRIBUTES).all_met?
    end

    private

    attr_reader :rule, :transaction, :user, :client
  end
end
