module PointRules
  class Point
    attr_accessor :base_points, :multiplier

    def initialize(base_points: 0, multiplier: 0)
      @base_points = base_points
      @multiplier = multiplier
    end

    def points
      base_points * (1 + multiplier)
    end

    def add(point)
      self.base_points += point.base_points
      self.multiplier += point.multiplier
    end
  end
end
