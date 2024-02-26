PROJECT_ID="knewhub"
SECRETS=("RAILS_MASTER_KEY" "WEB_URL" "POSTGRES_HOST" "POSTGRES_DB" "POSTGRES_USER" "POSTGRES_PASSWORD" "GITHUB_APP_ID" "GITHUB_APP_NAME" "GITHUB_CLIENT_ID" "GITHUB_CLIENT_SECRET" "GITHUB_PRIVATE_KEY" "BREVO_USERNAME" "BREVO_PASSWORD")

function get_secret() {
    curl "https://secretmanager.googleapis.com/v1/projects/$PROJECT_ID/secrets/$1/versions/latest:access" \
    --request "GET" \
    --header "authorization: Bearer $(gcloud auth print-access-token)" \
    --header "content-type: application/json" \
    | jq -r ".payload.data" | base64 --decode
}

for secret in ${SECRETS[@]}; do
    export $secret="$(get_secret $secret)"
done