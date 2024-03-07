class AutodeskFileUpload < Autodesk
  def initialize(filepath, build)
    super()
    @filepath = filepath
    @build = build
    write_access_token_log
  end

  def upload_file_for_viewer
    return unless allowed_to_upload_file?

    base64_urn = start_upload

    translate_job_response = translate_to_svf(base64_urn)
    urn_encoded = JSON.parse(translate_job_response.body)['urn']

    verify_response = verify_job_complete(urn_encoded)
    verify_response_as_json = JSON.parse(verify_response.body)

    update_build(verify_response_as_json)
    verify_response_as_json['urn'] if verify_response_as_json['status'] == 'success'
  end

  private

  def write_access_token_log
    if @access_token
      @build.logs.create(content: 'Autodesk access token successfully created.')
    else
      @build.logs.create(
        content: "Failed to create Autodesk access token. Error: '#{@access_token_error_msg}'",
        failure: true
      )
    end
  end

  def allowed_to_upload_file?
    return true if @access_token

    @build.logs.create(
      content: 'Unable to upload file to Autodesk server due to invalid access token.',
      failure: true
    )
    false
  end

  def bucket_signed_url
    response = @conn.get(
      "/oss/v2/buckets/#{@bucket_key}/objects/#{CGI.escape(@filepath)}/signeds3upload?minutesExpiration=10",
      nil,
      { 'Content-Type': 'application/json', Authorization: "Bearer #{@access_token}" }
    )
    response_as_json = JSON.parse(response.body)
    { upload_key: response_as_json['uploadKey'], urls: response_as_json['urls'] }
  end

  def finalize_upload(upload_key)
    request_params = { ossbucketKey: upload_key, ossSourceFileObjectKey: CGI.escape(@filepath), access: 'full',
                        uploadKey: upload_key }
    response = @conn.post(
      "/oss/v2/buckets/#{@bucket_key}/objects/#{CGI.escape(@filepath)}/signeds3upload",
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

  def start_upload
    upload_key, urls = bucket_signed_url.values
    upload_url = urls.first

    conn = Faraday.new(url: upload_url)
    conn.put(
      '',
      File.binread(@filepath),
      { 'Content-Type': 'application/octet-stream' }
    )

    finalize_upload(upload_key)
  end

  def update_build(response_as_json)
    if response_as_json['status'] == 'success'
      @build.logs.create(content: "'#{@filepath}' successfully uploaded to Autodesk servers.")
    else
      content = <<~MSG
        Failed to upload '#{@filepath}' to Autodesk servers.
        Status: #{verify_response_as_json['derivatives']['status']}.
        Message: #{verify_response_as_json['derivatives']['messages']}
      MSG
      @build.logs.create(content:, failure: true)
    end
  end
end
