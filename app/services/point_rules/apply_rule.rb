module PointRules
  class ApplyRule
    def self.call(rule:, transaction:)
      new(rule:, transaction:).call
    end

    def initialize(rule:, transaction:)
      @rule = rule
      @transaction = transaction
    end

    def call
      return Point.new unless Applicable.call(rule:, transaction:)

      calculate_points(rule.actions, transaction)
    end

    private

    attr_reader :rule, :transaction

    def calculate_points(actions, transaction)
      base_points = 0
      multiplier = 0

      if actions["points"] && actions["per"]
        # e.g., { points: 10, per: 10000 }
        base_points += (transaction.amount_in_cents / actions["per"]) * actions["points"]
      end

      if actions["multiplier"]
        multiplier += actions["multiplier"]
      end

      if actions["points"] && !actions["per"]
        base_points += actions["points"]
      end

      Point.new(base_points: base_points, multiplier: multiplier)
    end
  end
end
