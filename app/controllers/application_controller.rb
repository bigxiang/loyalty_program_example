class ApplicationController < ActionController::API
  include AbstractController::Translation

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: { error: t("not_found") }, status: :not_found
  end

  rescue_from StandardError do |exception|
    Rails.logger.error(exception)

    render json: { error: t("internal_server_error") }, status: :internal_server_error
  end

  def route_not_found
    render json: { error: t("not_found") }, status: :not_found
  end
end
