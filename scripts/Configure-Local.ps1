# Nhập thông tin kết nối SQL Server và lưu cấu hình riêng cho máy chạy API.
# Chạy trước Setup-Database.ps1; tệp appsettings.Local.json bị .gitignore loại trừ, không đưa lên GitHub.
# Server mặc định là tên máy hiện tại; có thể truyền -Server nếu SQL Server nằm ở instance hoặc máy khác.
# Database chỉ nhận chữ cái đầu và các ký tự chữ/số/gạch dưới để tên dùng được an toàn trong script SQL.
param(
    [string]$Server = $env:COMPUTERNAME,
    [ValidatePattern('^[A-Za-z][A-Za-z0-9_]*$')][string]$Database = 'PhoneStoreDb',
    [string]$UserName = 'sa'
)
# Dừng khi gặp lỗi PowerShell thay vì tiếp tục tạo cấu hình thiếu hoặc sai.
$ErrorActionPreference = 'Stop'
# Nhập kín bằng SecureString để không hiện mật khẩu trên màn hình.
# Khi ghi thành chuỗi kết nối JSON, mật khẩu vẫn là văn bản đọc được: đây không phải tệp đã mã hóa.
$password = Read-Host 'Mật khẩu SQL Server (không lưu vào Git)' -AsSecureString
# Đổi SecureString sang vùng nhớ tạm mà .NET có thể đọc để tạo chuỗi kết nối.
$pointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
try {
    $plain = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($pointer)
    # Dùng bộ dựng chuỗi kết nối để xử lý ký tự đặc biệt đúng quy tắc, tránh tự nối mật khẩu vào chuỗi.
    # Dùng khóa chuẩn như Data Source trong dấu [] để tương thích cách PowerShell xử lý đối tượng này.
    $builder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder
    $builder['Data Source'] = $Server
    $builder['Initial Catalog'] = $Database
    $builder['User ID'] = $UserName
    $builder['Password'] = $plain
    # Bật mã hóa đường truyền SQL. TrustServerCertificate chấp nhận chứng chỉ cục bộ chưa được tin cậy,
    # phù hợp máy thực hành; không đồng nghĩa đã xác minh danh tính máy chủ bằng chứng chỉ.
    # Connect Timeout giới hạn thời gian thiết lập kết nối là 5 giây, không phải thời gian tối đa của mọi truy vấn.
    $builder['Encrypt'] = $true
    $builder['TrustServerCertificate'] = $true
    $builder['Connect Timeout'] = 5
    # Tạo đúng cấu trúc ConnectionStrings:PhoneStore để Program.cs đọc bằng GetConnectionString.
    # PSScriptRoot là thư mục chứa script, nên tìm cấu hình không phụ thuộc terminal đang đứng ở đâu.
    $settings = @{ ConnectionStrings = @{ PhoneStore = $builder.ConnectionString } }
    $path = Join-Path $PSScriptRoot '../backend/PhoneApi/appsettings.Local.json'
    $settings | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $path -Encoding UTF8
    Write-Host 'Đã lưu cấu hình cục bộ. Tệp này được .gitignore loại trừ.'
} finally {
    # finally luôn chạy sau phần try, kể cả khi lỗi: xóa và giải phóng vùng nhớ BSTR tạm.
    # Gán plain về null bỏ tham chiếu biến, không đảm bảo mọi bản sao chuỗi .NET đã bị xóa khỏi bộ nhớ.
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($pointer)
    $plain = $null
}
