$branch = (git branch --show-current)
$remote = (git config --get remote.origin.url)
$hash = (git rev-parse HEAD)
Write-Output "{`"branch`": `"$branch`", `"remote`": `"$remote`", `"hash`": `"$hash`"}"