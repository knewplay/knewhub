class Autodesk
  def access_token
    conn = Faraday.new(url: 'https://developer.api.autodesk.com')
    response = conn.post(
      '/authentication/v2/token',
      { grant_type: 'client_credentials', scope: 'data:read data:write bucket:create' },
      { 'Content-Type': 'application/x-www-form-urlencoded',
        Accept: 'application/json',
        Authorization: "Basic #{base64_client_info}" }
    )
    response_as_json = JSON.parse(response.body)
    response_as_json['access_token']
  end

  private

  def base64_client_info
    client_id = Rails.application.credentials.dig(:autodesk, :client_id)
    client_secret = Rails.application.credentials.dig(:autodesk, :client_secret)
    Base64.strict_encode64("#{client_id}:#{client_secret}")
  end
end
