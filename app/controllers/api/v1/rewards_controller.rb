module Api
  module V1
    class RewardsController < ApplicationController
      def issue
        service = Rewards::Issue.new(user_identifier: rewards_params[:user_identifier])

        if service.invalid?
          render json: { message: t(".error"), errors: service.errors.full_messages }, status: :unprocessable_entity
        else
          result = service.call

          if result.success?
            render json: { message: t(".success"), data: result.data }, status: :ok
          else
            render json: { message: t(".error"), errors: result.errors }, status: :unprocessable_entity
          end
        end
      end

      private

      def rewards_params
        params.permit(:user_identifier)
      end
    end
  end
end
