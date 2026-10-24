# Kiểm thử HTTP của phần Gia Huy khi API và SQL Server đang chạy; không tự tạo dữ liệu hoặc sửa DB.
# Kiểm tra API/ảnh không thay thế kiểm thử giao diện hai màn Flutter của Thanh Sơn.
# BaseUrl mặc định dành cho máy tính; có thể đổi để kiểm tra một địa chỉ API khác.
# Bộ kiểm thử này giả định DB đã nạp ít nhất 7 điện thoại mẫu, không dùng để kiểm tra trường hợp DB rỗng.
param([string]$BaseUrl = 'http://localhost:5000')
$ErrorActionPreference = 'Stop'
# Bỏ dấu / cuối địa chỉ để khi ghép endpoint không bị thành hai dấu / liên tiếp.
$BaseUrl = $BaseUrl.TrimEnd('/')
# Hàm kiểm tra điều kiện: sai thì dừng bằng ngoại lệ; đúng thì in kết quả để biết ca nào đã đi qua.
function Check([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw "FAIL: $Message" }
    Write-Host "PASS: $Message"
}
# Gửi GET và so sánh mã HTTP thực tế với mong đợi; trả nội dung đã chuyển từ JSON thành đối tượng PowerShell.
function Request([string]$Path, [int]$Status) {
    $actualStatus = 0; $body = ''
    try {
        # Giới hạn thời gian chờ 15 giây để bộ thử không treo vô hạn khi API không phản hồi.
        $response = Invoke-WebRequest "$BaseUrl$Path" -UseBasicParsing -TimeoutSec 15
        $actualStatus = [int]$response.StatusCode; $body = $response.Content
    # Invoke-WebRequest ném ngoại lệ với HTTP 400/404; đây có thể chính là kết quả ca thử đang mong đợi.
    # Nếu không có phản hồi HTTP, ví dụ không kết nối được máy chủ, ném lại lỗi thay vì coi là kiểm thử đạt.
    } catch {
        if (-not $_.Exception.Response) { throw }
        $actualStatus = [int]$_.Exception.Response.StatusCode
        $body = $_.ErrorDetails.Message
        # Một số môi trường đặt nội dung lỗi trong luồng phản hồi thay vì ErrorDetails.
        # Đọc phần nội dung đó để vẫn kiểm tra được mã lỗi JSON; luôn đóng bộ đọc sau khi dùng.
        if ([string]::IsNullOrWhiteSpace($body)) {
            $reader = New-Object IO.StreamReader($_.Exception.Response.GetResponseStream())
            try { $body = $reader.ReadToEnd() } finally { $reader.Dispose() }
        }
    }
    Check ($actualStatus -eq $Status) "$Path => HTTP $Status"
    return ConvertFrom-Json -InputObject $body
}
# Kiểm tra danh sách trước, rồi dùng chính các id trả về để kiểm tra chi tiết, tránh chọn nhầm sản phẩm.
$phones = Request '/api/phones' 200
Check ($phones.Count -ge 7) 'Có ít nhất 7 điện thoại'
$lastId = 0
foreach ($phone in $phones) {
    # So sánh tập tên thuộc tính sau khi sắp xếp: phải đúng 5 trường đã chốt, không phụ thuộc thứ tự khóa JSON.
    $keys = @($phone.PSObject.Properties.Name | Sort-Object) -join ','
    Check ($keys -eq 'description,id,imageUrl,name,price') "JSON đúng 5 trường của id=$($phone.id)"
    # Kiểm tra id tăng dần và giá không âm; không yêu cầu các id liên tiếp vì IDENTITY có thể có khoảng trống.
    Check ($phone.id -gt $lastId -and $phone.price -ge 0) 'Id tăng dần và giá hợp lệ'
    $lastId = $phone.id
    Check (-not [string]::IsNullOrWhiteSpace($phone.name)) 'Tên không rỗng'
    Check (-not [string]::IsNullOrWhiteSpace($phone.description)) 'Mô tả không rỗng'
    # Đối chiếu cả 5 trường giữa danh sách và chi tiết của cùng một id.
    $detail = Request "/api/phones/$($phone.id)" 200
    foreach ($field in @('id','name','price','imageUrl','description')) {
        Check ($detail.$field -eq $phone.$field) "Chi tiết khớp danh sách: $field"
    }
    # Kiểm tra URL ảnh dùng host bên gọi và tải được với kiểu nội dung JPEG.
    # Phép thử này kiểm tra HTTP và Content-Type; việc kiểm tra chữ ký tệp ảnh đã được thực hiện trong lần kiểm thử sâu.
    Check ($phone.imageUrl.StartsWith("$BaseUrl/images/")) 'URL ảnh dùng host của thiết bị gọi'
    $imageResponse = Invoke-WebRequest $phone.imageUrl -UseBasicParsing -TimeoutSec 10
    Check ($imageResponse.StatusCode -eq 200 -and $imageResponse.Headers['Content-Type'] -match '^image/jpeg') 'Ảnh JPEG truy cập được'
}
# Thử id bằng 0, âm, chữ, vượt Int32 và số thập phân: tất cả phải trả 400 cùng mã INVALID_ID.
foreach ($id in @('0','-1','abc','2147483648','1.5')) {
    $errorResult = Request "/api/phones/$id" 400
    Check ($errorResult.code -eq 'INVALID_ID') 'Mã lỗi INVALID_ID'
}
# Danh sách đã sắp xếp tăng dần nên id cuối + 1 chưa xuất hiện tại thời điểm lấy danh sách.
# Giả định không có tiến trình khác thêm điện thoại trong lúc thử; trường hợp này phải trả 404 thay vì 400.
$missingId = [int]$lastId + 1
$errorResult = Request "/api/phones/$missingId" 404
Check ($errorResult.code -eq 'PHONE_NOT_FOUND') 'Mã lỗi PHONE_NOT_FOUND'
Write-Host 'Đã hoàn tất kiểm thử API và ảnh. Kiểm thử UI Flutter thuộc phần Thanh Sơn.'
