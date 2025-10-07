<#
    get_laptop_ip.ps1
    Detects Windows laptop IP address for WiFi/Ethernet/Hotspot adapters,
    exports to LAPTOP_IP environment variable, and displays formatted output for Flutter development.
#>

if ((Get-ExecutionPolicy) -eq 'Restricted') {
    Write-Host "Execution policy is Restricted. Please run: Set-ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor Red
    exit 1
}

$adapterPatterns = @('Wi-Fi', 'WiFi', 'Wireless', 'Hotspot', 'Ethernet')
$ip = $null

foreach ($pattern in $adapterPatterns) {
    $ipObj = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {
        $_.InterfaceAlias -like "*$pattern*" -and $_.IPAddress -notlike "169.254*" -and $_.IPAddress -ne $null
    } | Select-Object -First 1
    if ($ipObj) {
        $ip = $ipObj.IPAddress
        break
    }
}

if (-not $ip) {
    Write-Host "No active network connection found for WiFi/Ethernet/Hotspot adapters." -ForegroundColor Red
    exit 1
}

$env:LAPTOP_IP = $ip

# Save IP to .env file for Flutter project
$envFilePath = "./frontend_flutter/.env"
"API_HOST=$ip" | Set-Content $envFilePath

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Your laptop IP: $ip" -ForegroundColor Green
Write-Host "Use this in Flutter: http://$ip:5000/api" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Cyan$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -notlike "169.*"} | Select-Object -First 1 -ExpandProperty IPAddress)
[System.Environment]::SetEnvironmentVariable('LAPTOP_IP', $ip, 'User')
Write-Host "LAPTOP_IP set to $ip"
