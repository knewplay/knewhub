class AutodeskBucket < Autodesk
  def initialize
    super(scope: 'data:read bucket:create')
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
    request_params = { bucketKey: @bucket_key, access: 'full', policyKey: 'persistent' }
    response = @conn.post(
      '/oss/v2/buckets',
      request_params.to_json,
      { 'Content-Type': 'application/json', Authorization: "Bearer #{@access_token}" }
    )
    JSON.parse(response.body)
  end
end
