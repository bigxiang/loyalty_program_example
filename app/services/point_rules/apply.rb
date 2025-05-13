module PointRules
  class Apply
    def self.call(transaction:)
      new(transaction:).call
    end

    def initialize(transaction:)
      @transaction = transaction
    end

    def call
      transaction.available_point_rules.each_with_object(Point.new) do |rule, point|
        point.add(ApplyRule.call(rule:, transaction:))
      end
    end

    private

    attr_reader :transaction
  end
end
