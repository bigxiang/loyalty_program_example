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
      conditions_met?(rule.conditions, context_objects)
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

    def conditions_met?(conditions, context_objects)
      conditions.all? do |context, attrs|
        obj = context_objects[context.to_sym]
        next false unless obj

        attrs.all? do |attr, ops|
          ensure_attribute_is_whitelisted(context, attr)
          value = obj.public_send(attr)
          ops.all? do |op, cond_val|
            cond_val = evaluate_dynamic(cond_val, context_objects)
            compare(value, op, cond_val)
          end
        end
      end
    end

    def compare(value, op, cond_val)
      case op.to_s
      when "gte" then value >= cond_val
      when "lte" then value <= cond_val
      when "gt"  then value > cond_val
      when "eq"  then value == cond_val
      else raise NotImplementedError, "Operator #{op} not implemented"
      end
    end

    def evaluate_dynamic(val, context_objects)
      keys = WHITELISTED_ATTRIBUTES.keys.map(&:to_s)
      dynamic_regexp = /\{(#{keys.join('|')})([.\w() ,\-?!]*)\}/
      return val unless val.is_a?(String)

      match = val.match(dynamic_regexp)
      return val unless match

      context_key = match[1]
      code = match[2].strip

      obj = context_objects[context_key.to_sym]
      raise NotImplementedError, "Unknown context: #{context_key}" unless obj

      # Handle method calls
      # e.g. .months_ago(2) or .monthly_points()
      method_call_regexp = /^\.?([a-zA-Z_][\w]*)\((.*)\)$/
      if code =~ method_call_regexp
        method = $1
        ensure_attribute_is_whitelisted(context_key, method)
        args = $2.split(",").map(&:strip).map { |a| parse_arg(a) }
        obj.public_send(method, *args)
      elsif code.start_with?(".")
        attribute = code[1..-1]
        ensure_attribute_is_whitelisted(context_key, attribute)
        obj.public_send(attribute)
      else
        raise NotImplementedError, "Invalid dynamic code: #{code}"
      end
    end

    def ensure_attribute_is_whitelisted(context, attr)
      if !WHITELISTED_ATTRIBUTES[context.to_sym].include?(attr.to_sym)
        raise NotImplementedError, "Attribute #{attr} not implemented"
      end
    end

    def parse_arg(arg)
      if arg.match?(/\A\d+\z/)
        arg.to_i
      elsif arg.match?(/\A\d+\.\d+\z/)
        arg.to_f
      elsif arg == "true"
        true
      elsif arg == "false"
        false
      elsif arg.match?(/\A['"].*['"]\z/)
        arg[1..-2] # remove surrounding quotes
      else
        arg # fallback: return as string
      end
    end
  end
end
