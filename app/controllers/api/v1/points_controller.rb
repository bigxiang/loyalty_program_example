module Api
  module V1
    class PointsController < ApplicationController
      # POST /api/v1/points/earn
      def earn
        service = Api::V1::Points::Earn.new(
          user_identifier: points_params[:user_identifier],
          birthday: points_params[:birthday],
          transaction_identifier: points_params[:transaction_identifier],
          is_foreign: points_params[:is_foreign],
          amount_in_cents: points_params[:amount_in_cents]
        )

        if service.invalid?
          render json: { message: t(".error"), errors: service.errors.full_messages }, status: :unprocessable_entity
          nil
        else
          result = service.call

          if result.success?
            render json: { message: t(".success"), data: result.data }, status: :ok
          else
            render json: { message: t(".error"), errors: result.errors }, status: :unprocessable_entity
          end
        end
      end

      def points_params
        params
          .permit(:user_identifier, :birthday, :transaction_identifier, :is_foreign, :amount_in_cents)
          .merge(is_foreign: ActiveModel::Type::Boolean.new.cast(params[:is_foreign]))
          .merge(amount_in_cents: ActiveModel::Type::Integer.new.cast(params[:amount_in_cents]))
      end
    end
  end
end
