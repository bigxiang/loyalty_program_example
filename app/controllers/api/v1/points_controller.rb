module Api
  module V1
    class PointsController < ApplicationController
      # POST /api/v1/points/earn
      def earn
        render json: { message: t(".success") }, status: :ok
      end
    end
  end
end
