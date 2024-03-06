class AutodeskBucket < Autodesk
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
end
