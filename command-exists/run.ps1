$command = $args[0]
if ([bool](Get-Command -Name "$command" -ErrorAction SilentlyContinue)) {
    Write-Output '{"exists": "true"}'
}
Else {
    Write-Output '{"exists": "false"}'
}