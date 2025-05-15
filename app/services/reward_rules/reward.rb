module RewardRules
  class Reward
    Item = Struct.new(:rule_id, :name, :quantity, keyword_init: true)

    attr_reader :items

    def initialize
      @items = []
    end

    def add(item)
      return if item.nil?

      items << item
    end
  end
end
