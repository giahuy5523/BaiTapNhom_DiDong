$ErrorActionPreference = 'Stop'
$project = Join-Path $PSScriptRoot '../backend/PhoneApi/PhoneApi.csproj'
& dotnet run --project $project --launch-profile http
if ($LASTEXITCODE -ne 0) { throw 'API đã dừng với lỗi.' }
