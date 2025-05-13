require 'rails_helper'

RSpec.describe PointRules::Point do
  describe '#initialize' do
    it 'sets base_points and multiplier' do
      point = described_class.new(base_points: 10, multiplier: 2)
      expect(point.instance_variable_get(:@base_points)).to eq(10)
      expect(point.instance_variable_get(:@multiplier)).to eq(2)
    end
  end

  describe '#points' do
    it 'calculates points as base_points * (1 + multiplier)' do
      point = described_class.new(base_points: 10, multiplier: 2)
      expect(point.points).to eq(30)
    end

    it 'returns 0 if base_points is 0' do
      point = described_class.new(base_points: 0, multiplier: 5)
      expect(point.points).to eq(0)
    end

    it 'returns base_points if multiplier is 0' do
      point = described_class.new(base_points: 10, multiplier: 0)
      expect(point.points).to eq(10)
    end
  end

  describe '#add' do
    it 'adds base_points and multiplier from another Point' do
      point1 = described_class.new(base_points: 10, multiplier: 2)
      point2 = described_class.new(base_points: 5, multiplier: 1)
      point1.add(point2)
      expect(point1.instance_variable_get(:@base_points)).to eq(15)
      expect(point1.instance_variable_get(:@multiplier)).to eq(3)
      expect(point1.points).to eq(60)
    end

    it 'adds from a Point with only base_points' do
      point1 = described_class.new(base_points: 10, multiplier: 2)
      point2 = described_class.new(base_points: 5)
      point1.add(point2)
      expect(point1.instance_variable_get(:@base_points)).to eq(15)
      expect(point1.instance_variable_get(:@multiplier)).to eq(2)
    end

    it 'adds from a Point with only multiplier' do
      point1 = described_class.new(base_points: 10, multiplier: 2)
      point2 = described_class.new(multiplier: 1)
      point1.add(point2)
      expect(point1.instance_variable_get(:@base_points)).to eq(10)
      expect(point1.instance_variable_get(:@multiplier)).to eq(3)
    end
  end
end
