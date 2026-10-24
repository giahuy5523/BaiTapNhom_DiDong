# Tạo CSDL/bảng và nạp dữ liệu mẫu, không khởi động API.
# Đọc cấu hình đã tạo bằng Configure-Local.ps1 rồi chạy schema.sql trước, seed.sql sau.
param()
$ErrorActionPreference = 'Stop'
# Đọc JSON cục bộ và phân tích chuỗi kết nối để lấy server, tài khoản, mật khẩu và tên DB.
# Không ghi cứng các thông tin đăng nhập vào script để người khác có thể tự cấu hình trên máy họ.
$config = Get-Content (Join-Path $PSScriptRoot '../backend/PhoneApi/appsettings.Local.json') -Raw | ConvertFrom-Json
$connection = New-Object System.Data.SqlClient.SqlConnectionStringBuilder($config.ConnectionStrings.PhoneStore)
# Kiểm tra tên CSDL trước khi thay vào biến SQL vì phần tên đối tượng không phải tham số truy vấn thông thường.
if ($connection.InitialCatalog -notmatch '^[A-Za-z][A-Za-z0-9_]*$') { throw 'Tên CSDL không hợp lệ.' }
# Lưu giá trị biến môi trường cũ để khôi phục sau khi chạy, tránh làm thay đổi cấu hình của terminal.
$previousPassword = $env:SQLCMDPASSWORD
try {
    # Truyền mật khẩu cho sqlcmd bằng biến môi trường, tránh đặt mật khẩu ở tham số -P trên dòng lệnh.
    # Biến môi trường này vẫn chứa bí mật và được tiến trình sqlcmd kế thừa; không in nó ra màn hình.
    $env:SQLCMDPASSWORD = $connection.Password
    # Thứ tự bắt buộc: phải có DB/bảng trước khi chèn dữ liệu mẫu.
    foreach ($file in @('schema.sql','seed.sql')) {
        # & gọi chương trình sqlcmd: -S server, -U tài khoản, -C chấp nhận chứng chỉ máy thực hành.
        # -b trả mã thoát lỗi khi SQL có lỗi; -f 65001 đọc UTF-8 để không hỏng tiếng Việt; -l 8 giới hạn chờ đăng nhập.
        # -v truyền biến DatabaseName, -i chọn tệp SQL; các đường dẫn lấy theo vị trí script.
        & sqlcmd -S $connection.DataSource -U $connection.UserID -C -b -f 65001 -l 8 -v "DatabaseName=$($connection.InitialCatalog)" -i (Join-Path $PSScriptRoot "../database/$file")
        # Kiểm tra mã thoát của chương trình ngoài; lỗi tạo bảng thì dừng, không cố chạy nạp dữ liệu tiếp.
        if ($LASTEXITCODE -ne 0) { throw "Không chạy được $file. Kiểm tra SQL Server và thông tin đăng nhập." }
    }
    Write-Host "Đã chuẩn bị CSDL $($connection.InitialCatalog)."
# Dù chạy thành công hay thất bại đều khôi phục SQLCMDPASSWORD của terminal về giá trị ban đầu.
} finally { $env:SQLCMDPASSWORD = $previousPassword }
