class Autodesk
  attr_reader :access_token, :access_token_error_msg

  def initialize
    @conn = Faraday.new(url: 'https://developer.api.autodesk.com')
    @bucket_key = Rails.application.credentials.dig(:autodesk, :bucket_key)
    create_access_token
  end

  private

  def create_access_token
    response = @conn.post(
      '/authentication/v2/token',
      { grant_type: 'client_credentials', scope: 'data:read data:write bucket:create' },
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
    client_id = Rails.application.credentials.dig(:autodesk, :client_id)
    client_secret = Rails.application.credentials.dig(:autodesk, :client_secret)
    Base64.strict_encode64("#{client_id}:#{client_secret}")
  end
end
