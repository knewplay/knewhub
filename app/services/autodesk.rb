class Autodesk
  attr_reader :access_token, :access_token_error_msg

  def initialize(scope: 'viewables:read')
    @conn = Faraday.new(url: 'https://developer.api.autodesk.com')
    @bucket_key = Rails.application.credentials.dig(:autodesk, :upload, :bucket_key)
    @scope = scope
    create_access_token
  end

  def call_viewer(request_type, path, format)
    @conn.get(
      "derivativeservice/v2/#{request_type}/#{request_path(path, format)}",
      nil,
      { Authorization: "Bearer #{@access_token}" }
    )
  end

  private

  def create_access_token
    response = @conn.post(
      '/authentication/v2/token',
      { grant_type: 'client_credentials', scope: @scope },
      { 'Content-Type': 'application/x-www-form-urlencoded',
        Accept: 'application/json',
        Authorization: "Basic #{base64_client_info}" }
    )
    handle_response(response)
  end

  def handle_response(response)
    response_body = JSON.parse(response.body)
    if response.status == 200
      @access_token = response_body['access_token']
    else
      @access_token_error_msg = response_body.values.join('. ')
    end
  end

  def base64_client_info
    client_id = Rails.application.credentials.dig(:autodesk, :upload, :client_id)
    client_secret = Rails.application.credentials.dig(:autodesk, :upload, :client_secret)
    Base64.strict_encode64("#{client_id}:#{client_secret}")
  end

  def request_path(path, format)
    result = CGI.escape(path)
    result.concat(".#{format}") unless format.nil?
    result
  end
end
