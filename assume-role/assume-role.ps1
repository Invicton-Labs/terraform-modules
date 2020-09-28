$jsonpayload = [Console]::In.ReadLine()

# Convert from JSON
$json = ConvertFrom-Json $jsonpayload

$awsOutput = aws sts assume-role --role-arn $json.iam_role --role-session-name $json.session --duration-seconds 18000 --profile $json.profile | Out-String
#$awsOutput = aws sts assume-role --role-arn arn:aws:iam::809195115170:role/ClipMoneyDevTerraform --role-session-name terraform-dev --profile clipmoney_terraform_admin | Out-String

$awsJSON = ConvertFrom-Json $awsOutput
Write-Output (ConvertTo-Json $awsJSON.Credentials)