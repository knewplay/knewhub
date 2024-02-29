class Autodesk
  def initialize
    @conn = Faraday.new(url: 'https://developer.api.autodesk.com')
    @bucket_key = Rails.application.credentials.dig(:autodesk, :bucket_key)
    @access_token = create_access_token
  end

  def create_storage_bucket
    request_params = { bucketKey: @bucket_key, access: 'full', policyKey: 'transient' }
    response = @conn.post(
      '/oss/v2/buckets',
      request_params.to_json,
      { 'Content-Type': 'application/json', Authorization: "Bearer #{@access_token}" }
    )
    JSON.parse(response.body)
  end

  def upload_file(filepath)
    upload_key, urls = bucket_signed_url(filepath).values
    upload_url = urls.first

    conn = Faraday.new(url: upload_url)
    conn.put(
      '',
      filepath,
      { 'Content-Type': 'application/octet-stream' }
    )

    finalize_upload(filepath, upload_key)
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

  def bucket_signed_url(filepath)
    response = @conn.get(
      "/oss/v2/buckets/#{@bucket_key}/objects/#{CGI.escape(filepath)}/signeds3upload?minutesExpiration=10",
      nil,
      { 'Content-Type': 'application/json', Authorization: "Bearer #{@access_token}" }
    )
    response_as_json = JSON.parse(response.body)
    { upload_key: response_as_json['uploadKey'], urls: response_as_json['urls'] }
  end

  def finalize_upload(filepath, upload_key)
    request_params = { ossbucketKey: upload_key, ossSourceFileObjectKey: CGI.escape(filepath),
                       access: 'full', uploadKey: upload_key }
    response = @conn.post(
      "/oss/v2/buckets/#{@bucket_key}/objects/#{CGI.escape(filepath)}/signeds3upload",
      request_params.to_json,
      { 'Content-Type': 'application/json', Authorization: "Bearer #{@access_token}" }
    )
    response_as_json = JSON.parse(response.body)
    base64_urn(response_as_json)
  end

  def base64_urn(response_as_json)
    urn = response_as_json['objectId']
    Base64.urlsafe_encode64(urn)
  end
end
