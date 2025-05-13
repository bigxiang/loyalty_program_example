class ApplicationController < ActionController::API
  include AbstractController::Translation

  before_action :authenticate_client!

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

  private

  def authenticate_client!
    return if current_client

    render json: { error: t("unauthorized") }, status: :unauthorized
  end

  def current_client
    # TODO: Add a better way to authenticate the client
    Current.client ||= Client.find_by(id: request.headers["X-Client-Id"])
  end
end
