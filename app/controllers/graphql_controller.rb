# The API's only HTTP entry point: turns a POST /graphql into one schema call.
class GraphqlController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :set_current_request_details
  rescue_from JSON::ParserError, with: :render_malformed_variables

  def execute
    result = BdAssistantApiSchema.execute(
      params[:query],
      variables: graphql_variables,
      operation_name: params[:operationName],
      context: { current_session: Current.session, current_user: Current.user, ip_address: Current.ip_address }
    )

    render json: result
  end

  private

  def set_current_request_details
    Current.ip_address = request.remote_ip
    Current.user_agent = request.user_agent
    Current.session = authenticated_session
  end

  # A missing, unknown, expired or blocked token counts as signed out, so each
  # operation decides for itself whether it needs a signed-in user.
  def authenticated_session
    session = authenticate_with_http_token { |token, _options| Session.find_by_token(token) }
    return unless session&.user&.can_sign_in?

    session.record_activity!
    session
  end

  def render_malformed_variables
    render json: { errors: [{ message: I18n.t("errors.malformed_request"), extensions: { code: "BAD_REQUEST" } }] },
           status: :bad_request
  end

  # Clients send variables either as a JSON object or as a JSON string.
  def graphql_variables
    case (variables = params[:variables])
    when String then variables.present? ? JSON.parse(variables) : {}
    when ActionController::Parameters then variables.to_unsafe_h
    else {}
    end
  end
end
