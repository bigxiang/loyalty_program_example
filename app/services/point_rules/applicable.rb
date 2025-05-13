
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
      @end_user = transaction.end_user
      @client = transaction.client
    end

    def call
      return false unless rule.active
      return false if rule.level > end_user.level
      return false if rule.client != client

      conditions_met?(rule.conditions, end_user, transaction)
    end

    private

    attr_reader :rule, :transaction, :end_user, :client

    def conditions_met?(conditions, end_user, transaction)
      conditions.all? do |key, cond|
        case key.to_s
        when "transaction"
          cond.all? do |attr, ops|
            ensure_attribute_is_whitelisted(key, attr)
            all_ops_true?(ops, object: transaction, attr: attr)
          end
        else
          raise NotImplementedError, "Condition key #{key} not implemented"
        end
      end
    end

    def ensure_attribute_is_whitelisted(object, attr)
      if !WHITELISTED_ATTRIBUTES[object.to_sym].include?(attr.to_sym)
        raise NotImplementedError, "Attribute #{attr} not implemented"
      end
    end

    def all_ops_true?(ops, object:, attr:)
      ops.all? do |op, value|
        case op.to_s
        when "gte" then object.public_send(attr) >= value
        when "eq" then object.public_send(attr) == value
        else raise NotImplementedError, "Operator #{op} not implemented"
        end
      end
    end
  end
end
