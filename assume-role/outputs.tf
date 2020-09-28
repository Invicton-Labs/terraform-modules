output "credentials" {
  value = {
    access_key_id     = data.external.assumed-role-creds.result.AccessKeyId
    secret_access_key = data.external.assumed-role-creds.result.SecretAccessKey
    session_token     = data.external.assumed-role-creds.result.SessionToken
  }
}
