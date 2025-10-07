$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*"} | Select-Object -First 1 -ExpandProperty IPAddress)
Write-Host "Your laptop IP is: $ip"
