module Rules
  # The ConditionsChecker class is responsible for evaluating whether a rule's conditions are met
  # based on the provided context objects and whitelisted attributes.
  #
  # @example Basic usage with transaction conditions
  #   rule = PointRule.new(
  #     conditions: {
  #       transaction: {
  #         amount_in_cents: { gte: 1000 },
  #         is_foreign: { eq: true }
  #       }
  #     }
  #   )
  #   context_objects = { transaction: transaction }
  #   whitelisted_attributes = { transaction: [:amount_in_cents, :is_foreign] }
  #   checker = ConditionsChecker.new(rule: rule, context_objects: context_objects, whitelisted_attributes: whitelisted_attributes)
  #   checker.all_met? # Returns true if transaction amount >= 1000 and is_foreign is true
  #
  # @example Using dynamic time conditions
  #   rule = RewardRule.new(
  #     conditions: {
  #       user: {
  #         registered_at: { gte: "{current.months_ago(2)}" }
  #       }
  #     }
  #   )
  #   context_objects = { user: user, current: Time.current }
  #   whitelisted_attributes = { user: [:registered_at], current: [:months_ago] }
  #   checker = ConditionsChecker.new(rule: rule, context_objects: context_objects, whitelisted_attributes: whitelisted_attributes)
  #   checker.all_met? # Returns true if user registered within last 2 months
  #
  # @note Supported operators:
  #   - gte: greater than or equal to
  #   - lte: less than or equal to
  #   - gt: greater than
  #   - eq: equal to
  #
  # @note Dynamic values:
  #   - Can use {context.method(args)} syntax to evaluate dynamic values
  #   - Methods must be whitelisted in the context's whitelisted_attributes
  #   - Supports method calls with arguments: {current.months_ago(2)}
  #   - Supports attribute access: {user.monthly_points}
  class ConditionsChecker
    # @param rule [PointRule, RewardRule] The rule containing conditions to check
    # @param context_objects [Hash] A hash of context objects available for condition evaluation
    # @param whitelisted_attributes [Hash] A hash mapping context keys to arrays of allowed attributes/methods
    def initialize(rule:, context_objects:, whitelisted_attributes: {})
      @rule = rule
      @context_objects = context_objects
      @whitelisted_attributes = whitelisted_attributes
    end

    # Checks if all conditions in the rule are met
    # @return [Boolean] true if all conditions are met, false otherwise
    def all_met?
      conditions_met?(rule.conditions)
    end

    private

    attr_reader :rule, :context_objects, :whitelisted_attributes

    # Evaluates all conditions for a given context
    # @param conditions [Hash] The conditions to evaluate
    # @return [Boolean] true if all conditions are met
    def conditions_met?(conditions)
      conditions.all? { |context, attrs| condition_met?(context, attrs) }
    end

    # Evaluates a single condition for a specific context
    # @param context [Symbol] The context to evaluate (e.g., :transaction, :user)
    # @param attrs [Hash] The attributes and their conditions to check
    # @return [Boolean] true if all attributes meet their conditions
    # @raise [NotImplementedError] if context is unknown or attribute is not whitelisted
    def condition_met?(context, attrs)
      obj = fetch_object_from_context(context)
      raise NotImplementedError, "Unknown context: #{context}" unless obj

      attrs.all? do |attr, ops|
        ensure_attribute_is_whitelisted(context, attr)
        value = obj.public_send(attr)
        ops.all? do |op, expected|
          expected = evaluate_dynamic(expected)
          compare(value, op, expected)
        end
      end
    end

    # Fetches an object from the context by its key
    # @param context [Symbol] The context key to fetch
    # @return [Object] The context object or nil if not found
    def fetch_object_from_context(context)
      context_objects[context.to_sym]
    end

    # Compares a value with an expected value using the specified operator
    # @param value [Object] The value to compare
    # @param op [String] The operator to use (gte, lte, gt, eq)
    # @param expected [Object] The expected value to compare against
    # @return [Boolean] true if the comparison is true
    # @raise [NotImplementedError] if the operator is not supported
    def compare(value, op, expected)
      case op.to_s
      when "gte" then value >= expected
      when "lte" then value <= expected
      when "gt"  then value > expected
      when "eq"  then value == expected
      else raise NotImplementedError, "Operator #{op} not implemented"
      end
    end

    # Evaluates a dynamic value if it contains a dynamic expression
    # @param val [Object] The value to evaluate
    # @return [Object] The evaluated value or the original value if not dynamic
    def evaluate_dynamic(val)
      return val unless val.is_a?(String)

      match = match_dynamic_code(val)
      return val unless match

      context_key = match[1]
      code = match[2].strip
      evaluate_method_or_attribute(context_key, code)
    end

    # Matches a dynamic code expression in a string
    # @param val [String] The string to check for dynamic code
    # @return [MatchData, nil] The match data if found, nil otherwise
    def match_dynamic_code(val)
      keys = whitelisted_attributes.keys.map(&:to_s)
      dynamic_regexp = /\{(#{keys.join('|')})([.\w() ,\-?!]*)\}/
      val.match(dynamic_regexp)
    end

    # Evaluates a method call or attribute access on a context object
    # @param context_key [String] The context key to use
    # @param code [String] The code to evaluate
    # @return [Object] The result of the evaluation
    # @raise [NotImplementedError] if the context is unknown or the code is invalid
    def evaluate_method_or_attribute(context_key, code)
      obj = fetch_object_from_context(context_key)
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

    # Ensures an attribute is whitelisted for a context
    # @param context [String] The context to check
    # @param attr [String] The attribute to check
    # @raise [NotImplementedError] if the attribute is not whitelisted
    def ensure_attribute_is_whitelisted(context, attr)
      if !whitelisted_attributes[context.to_sym]&.include?(attr.to_sym)
        raise NotImplementedError, "Attribute #{attr} not implemented"
      end
    end

    # Parses an argument string into an appropriate Ruby object
    # @param arg [String] The argument string to parse
    # @return [Object] The parsed argument
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
