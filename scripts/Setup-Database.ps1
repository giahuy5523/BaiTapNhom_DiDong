param()
$ErrorActionPreference = 'Stop'
$config = Get-Content (Join-Path $PSScriptRoot '../backend/PhoneApi/appsettings.Local.json') -Raw | ConvertFrom-Json
$connection = New-Object System.Data.SqlClient.SqlConnectionStringBuilder($config.ConnectionStrings.PhoneStore)
if ($connection.InitialCatalog -notmatch '^[A-Za-z][A-Za-z0-9_]*$') { throw 'Tên CSDL không hợp lệ.' }
$previousPassword = $env:SQLCMDPASSWORD
try {
    $env:SQLCMDPASSWORD = $connection.Password
    foreach ($file in @('schema.sql','seed.sql')) {
        & sqlcmd -S $connection.DataSource -U $connection.UserID -C -b -f 65001 -l 8 -v "DatabaseName=$($connection.InitialCatalog)" -i (Join-Path $PSScriptRoot "../database/$file")
        if ($LASTEXITCODE -ne 0) { throw "Không chạy được $file. Kiểm tra SQL Server và thông tin đăng nhập." }
    }
    Write-Host "Đã chuẩn bị CSDL $($connection.InitialCatalog)."
} finally { $env:SQLCMDPASSWORD = $previousPassword }
