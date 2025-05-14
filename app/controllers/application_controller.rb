class ApplicationController < ActionController::API
  include AbstractController::Translation
  include ActionController::HttpAuthentication::Token::ControllerMethods

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
    authenticate_or_request_with_http_token do |token, _options|
      Current.client = ApiKey.authenticate(token)&.client
    end
  end

  # Override the default implementation to return a 401 Unauthorized response with JSON.
  def request_http_token_authentication(realm = "Application", message = nil)
    render json: { error: message || t("unauthorized") },
           status: :unauthorized,
           headers: { "WWW-Authenticate" => %(Token realm="#{realm.gsub(/"/, "")}") }
  end
end
