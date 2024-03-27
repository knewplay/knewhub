# Autodesk documentation: https://aps.autodesk.com/en/docs/viewer/v7/developers_guide/overview/
class AutodeskFileUpload < Autodesk
  def initialize(filepath, build)
    super(scope: 'data:read data:write')
    @filepath = filepath
    @build = build
    write_access_token_log
  end

  def upload_file_for_viewer
    return unless allowed_to_upload_file?

    # Upload source file to Autodesk storage bucket
    upload_key, upload_url = bucket_signed_url.values
    start_upload(upload_url)
    base64_object_urn = finalize_upload(upload_key)

    # Translate source file into SVF format for Viewer
    base64_file_urn = translate_to_svf(base64_object_urn)
    translation_job_response_body = check_translation_job_complete(base64_file_urn)
    update_build_logs(translation_job_response_body)

    base64_file_urn if translation_job_response_body['status'] == 'success'
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
      "/oss/v2/buckets/#{@bucket_key}/objects/#{CGI.escape(@filepath)}/signeds3upload?minutesExpiration=10", nil,
      { 'Content-Type': 'application/json', Authorization: "Bearer #{@access_token}" }
    )
    if response.status == 200
      response_as_json = JSON.parse(response.body)
      { upload_key: response_as_json['uploadKey'], upload_url: response_as_json['urls'].first }
    else
      @build.logs.create(content: "Cannot create bucket signed url. Status code: #{response.status}", failure: true)
    end
  end

  def start_upload(upload_url)
    conn = Faraday.new(url: upload_url)
    response = conn.put(
      '',
      File.binread(@filepath),
      { 'Content-Type': 'application/octet-stream' }
    )
    return if response.status == 200

    @build.logs.create(
      content: "Error when uploading file '#{filepath}'. Status code: #{response.status}", failure: true
    )
  end

  def finalize_upload(upload_key)
    request_params = { ossbucketKey: upload_key, ossSourceFileObjectKey: CGI.escape(@filepath),
                       access: 'full', uploadKey: upload_key }
    response = @conn.post(
      "/oss/v2/buckets/#{@bucket_key}/objects/#{CGI.escape(@filepath)}/signeds3upload",
      request_params.to_json,
      { 'Content-Type': 'application/json', Authorization: "Bearer #{@access_token}" }
    )
    handle_response_finalize_upload(response)
  end

  def handle_response_finalize_upload(response)
    if response.status == 200
      response_as_json = JSON.parse(response.body)
      object_urn = response_as_json['objectId']
      Base64.urlsafe_encode64(object_urn)
    else
      @build.logs.create(
        content: "Error when uploading file '#{filepath}'. Status code: #{response.status}", failure: true
      )
      nil
    end
  end

  def translate_to_svf(base64_object_urn)
    request_params = { input: { urn: base64_object_urn }, output: { formats: [{ type: 'svf', views: %w[2d 3d] }] } }
    response = @conn.post(
      '/modelderivative/v2/designdata/job',
      request_params.to_json,
      { 'Content-Type': 'application/json', Authorization: "Bearer #{@access_token}", 'x-ads-force': 'true' }
    )
    handle_response_translate_to_svf(response)
  end

  def handle_response_translate_to_svf(response)
    response_body = JSON.parse(response.body)
    if response.status == 200 || response.status == 201
      response_body['urn']
    else
      content = <<~MSG
        Error when translating '#{filepath}' to SVF format. Status code: #{response.status}. Error: '#{response_body['diagnostic']}'
      MSG
      @build.logs.create(content:, failure: true)
      nil
    end
  end

  def check_translation_job_complete(base64_file_urn)
    is_complete = false

    until is_complete
      response = @conn.get(
        "/modelderivative/v2/designdata/#{base64_file_urn}/manifest", nil, { Authorization: "Bearer #{@access_token}" }
      )
      response_body = JSON.parse(response.body)
      response_body['progress'] == 'complete' ? is_complete = true : sleep(1)
    end

    response_body
  end

  def update_build_logs(translation_job_response_body)
    if translation_job_response_body['status'] == 'success'
      @build.logs.create(content: "'#{@filepath}' successfully uploaded to Autodesk servers.")
    else
      content = <<~MSG
        Failed to upload '#{@filepath}' to Autodesk servers.
        Status: #{translation_job_response_body['derivatives']['status']}.
        Message: #{translation_job_response_body['derivatives']['messages']}
      MSG
      @build.logs.create(content:, failure: true)
    end
  end
end
