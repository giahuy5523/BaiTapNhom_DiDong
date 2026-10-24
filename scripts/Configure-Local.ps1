param(
    [string]$Server = $env:COMPUTERNAME,
    [ValidatePattern('^[A-Za-z][A-Za-z0-9_]*$')][string]$Database = 'PhoneStoreDb',
    [string]$UserName = 'sa'
)
$ErrorActionPreference = 'Stop'
$password = Read-Host 'Mật khẩu SQL Server (không lưu vào Git)' -AsSecureString
$pointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
try {
    $plain = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($pointer)
    $builder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder
    $builder['Data Source'] = $Server
    $builder['Initial Catalog'] = $Database
    $builder['User ID'] = $UserName
    $builder['Password'] = $plain
    $builder['Encrypt'] = $true
    $builder['TrustServerCertificate'] = $true
    $builder['Connect Timeout'] = 5
    $settings = @{ ConnectionStrings = @{ PhoneStore = $builder.ConnectionString } }
    $path = Join-Path $PSScriptRoot '../backend/PhoneApi/appsettings.Local.json'
    $settings | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $path -Encoding UTF8
    Write-Host 'Đã lưu cấu hình cục bộ. Tệp này được .gitignore loại trừ.'
} finally {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($pointer)
    $plain = $null
}
