module Rules
  class ConditionsChecker
    def initialize(rule:, context_objects:, whitelisted_attributes: {})
      @rule = rule
      @context_objects = context_objects
      @whitelisted_attributes = whitelisted_attributes
    end

    def all_met?
      conditions_met?(rule.conditions)
    end

    private

    attr_reader :rule, :context_objects, :whitelisted_attributes

    def conditions_met?(conditions)
      conditions.all? { |context, attrs| condition_met?(context, attrs) }
    end

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

    def fetch_object_from_context(context)
      context_objects[context.to_sym]
    end

    def compare(value, op, expected)
      case op.to_s
      when "gte" then value >= expected
      when "lte" then value <= expected
      when "gt"  then value > expected
      when "eq"  then value == expected
      else raise NotImplementedError, "Operator #{op} not implemented"
      end
    end

    def evaluate_dynamic(val)
      return val unless val.is_a?(String)

      match = match_dynamic_code(val)
      return val unless match

      context_key = match[1]
      code = match[2].strip
      evaluate_method_or_attribute(context_key, code)
    end

    def match_dynamic_code(val)
      keys = whitelisted_attributes.keys.map(&:to_s)
      dynamic_regexp = /\{(#{keys.join('|')})([.\w() ,\-?!]*)\}/
      val.match(dynamic_regexp)
    end

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

    def ensure_attribute_is_whitelisted(context, attr)
      if !whitelisted_attributes[context.to_sym]&.include?(attr.to_sym)
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
