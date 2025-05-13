module Api
  module V1
    class Result
      attr_reader :data, :errors

      def initialize(success:, data: {}, errors: [])
        @success = success
        @data = data
        @errors = errors
      end

      def success?
        @success
      end
    end
  end
end
