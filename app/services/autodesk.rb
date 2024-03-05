class Autodesk
  def initialize
    @conn = Faraday.new(url: 'https://developer.api.autodesk.com')
    @bucket_key = Rails.application.credentials.dig(:autodesk, :bucket_key)
    @access_token = create_access_token
    @logger = Rails.logger
  end

  def upload_file_for_viewer(filepath)
    base64_urn = start_upload(filepath)

    translate_job_response = translate_to_svf(base64_urn)
    urn_encoded = JSON.parse(translate_job_response.body)['urn']

    verify_response = verify_job_complete(urn_encoded)
    verify_response_as_json = JSON.parse(verify_response.body)

    return unless verify_response_as_json['status'] == 'success'

    @logger.info 'Success. File will be added to viewer'
    verify_response_as_json['urn']
  end

  def query_storage_bucket_objects
    response = @conn.get(
      "/oss/v2/buckets/#{@bucket_key}/objects",
      nil,
      { 'Content-Type': 'application/json', Authorization: "Bearer #{@access_token}" }
    )
    JSON.parse(response.body)
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
    @logger.info "Finalizing upload of file '#{filepath}' to Autodesk bucket"
    request_params = { ossbucketKey: upload_key, ossSourceFileObjectKey: CGI.escape(filepath), access: 'full', uploadKey: upload_key }
    response = @conn.post(
      "/oss/v2/buckets/#{@bucket_key}/objects/#{CGI.escape(filepath)}/signeds3upload",
      request_params.to_json,
      { 'Content-Type': 'application/json', Authorization: "Bearer #{@access_token}" }
    )
    response_as_json = JSON.parse(response.body)
    urn = response_as_json['objectId']
    Base64.urlsafe_encode64(urn)
  end

  def translate_to_svf(base64_urn)
    request_params = {
      input: { urn: base64_urn },
      output: { formats: [{ type: 'svf', views: %w[2d 3d] }] }
    }
    @conn.post(
      '/modelderivative/v2/designdata/job',
      request_params.to_json,
      { 'Content-Type': 'application/json', Authorization: "Bearer #{@access_token}", 'x-ads-force': 'true' }
    )
  end

  def verify_job_complete(base_64_urn)
    is_complete = false

    until is_complete
      response = @conn.get(
        "/modelderivative/v2/designdata/#{base_64_urn}/manifest", nil, { Authorization: "Bearer #{@access_token}" }
      )
      response_as_json = JSON.parse(response.body)
      response_as_json['progress'] == 'complete' ? is_complete = true : sleep(1)
    end

    response
  end

  def start_upload(filepath)
    upload_key, urls = bucket_signed_url(filepath).values
    upload_url = urls.first

    conn = Faraday.new(url: upload_url)
    @logger.info "Starting upload of file '#{filepath}' to Autodesk bucket"
    conn.put(
      '',
      File.binread(filepath),
      { 'Content-Type': 'application/octet-stream' }
    )

    finalize_upload(filepath, upload_key)
  end
end
