$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -notlike "169.*"} | Select-Object -First 1 -ExpandProperty IPAddress)
[System.Environment]::SetEnvironmentVariable('LAPTOP_IP', $ip, 'User')
Write-Host "LAPTOP_IP set to $ip"
