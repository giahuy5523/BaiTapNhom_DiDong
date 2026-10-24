param([string]$BaseUrl = 'http://localhost:5000')
$ErrorActionPreference = 'Stop'
$BaseUrl = $BaseUrl.TrimEnd('/')
function Check([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw "FAIL: $Message" }
    Write-Host "PASS: $Message"
}
function Request([string]$Path, [int]$Status) {
    $actualStatus = 0; $body = ''
    try {
        $response = Invoke-WebRequest "$BaseUrl$Path" -UseBasicParsing -TimeoutSec 15
        $actualStatus = [int]$response.StatusCode; $body = $response.Content
    } catch {
        if (-not $_.Exception.Response) { throw }
        $actualStatus = [int]$_.Exception.Response.StatusCode
        $body = $_.ErrorDetails.Message
        if ([string]::IsNullOrWhiteSpace($body)) {
            $reader = New-Object IO.StreamReader($_.Exception.Response.GetResponseStream())
            try { $body = $reader.ReadToEnd() } finally { $reader.Dispose() }
        }
    }
    Check ($actualStatus -eq $Status) "$Path => HTTP $Status"
    return ConvertFrom-Json -InputObject $body
}
$phones = Request '/api/phones' 200
Check ($phones.Count -ge 7) 'Có ít nhất 7 điện thoại'
$lastId = 0
foreach ($phone in $phones) {
    $keys = @($phone.PSObject.Properties.Name | Sort-Object) -join ','
    Check ($keys -eq 'description,id,imageUrl,name,price') "JSON đúng 5 trường của id=$($phone.id)"
    Check ($phone.id -gt $lastId -and $phone.price -ge 0) 'Id tăng dần và giá hợp lệ'
    $lastId = $phone.id
    Check (-not [string]::IsNullOrWhiteSpace($phone.name)) 'Tên không rỗng'
    Check (-not [string]::IsNullOrWhiteSpace($phone.description)) 'Mô tả không rỗng'
    $detail = Request "/api/phones/$($phone.id)" 200
    foreach ($field in @('id','name','price','imageUrl','description')) {
        Check ($detail.$field -eq $phone.$field) "Chi tiết khớp danh sách: $field"
    }
    Check ($phone.imageUrl.StartsWith("$BaseUrl/images/")) 'URL ảnh dùng host của thiết bị gọi'
    $imageResponse = Invoke-WebRequest $phone.imageUrl -UseBasicParsing -TimeoutSec 10
    Check ($imageResponse.StatusCode -eq 200 -and $imageResponse.Headers['Content-Type'] -match '^image/jpeg') 'Ảnh JPEG truy cập được'
}
foreach ($id in @('0','-1','abc','2147483648','1.5')) {
    $errorResult = Request "/api/phones/$id" 400
    Check ($errorResult.code -eq 'INVALID_ID') 'Mã lỗi INVALID_ID'
}
$missingId = [int]$lastId + 1
$errorResult = Request "/api/phones/$missingId" 404
Check ($errorResult.code -eq 'PHONE_NOT_FOUND') 'Mã lỗi PHONE_NOT_FOUND'
Write-Host 'Đã hoàn tất kiểm thử API và ảnh. Kiểm thử UI Flutter thuộc phần Thanh Sơn.'
