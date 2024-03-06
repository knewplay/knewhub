class Autodesk
  attr_reader :access_token

  def initialize
    @conn = Faraday.new(url: 'https://developer.api.autodesk.com')
    @bucket_key = Rails.application.credentials.dig(:autodesk, :bucket_key)
    @access_token = create_access_token
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
    response_as_json = JSON.parse(response.body)
    response_as_json['access_token']
  end

  def base64_client_info
    client_id = Rails.application.credentials.dig(:autodesk, :client_id)
    client_secret = Rails.application.credentials.dig(:autodesk, :client_secret)
    Base64.strict_encode64("#{client_id}:#{client_secret}")
  end
end
