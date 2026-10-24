# Khởi động API bằng hồ sơ http, không tạo CSDL hoặc nạp dữ liệu.
# Trước lần chạy đầu cần hoàn thành Configure-Local.ps1 và Setup-Database.ps1.
$ErrorActionPreference = 'Stop'
# Tìm project backend từ thư mục script để không phụ thuộc thư mục hiện tại của terminal.
$project = Join-Path $PSScriptRoot '../backend/PhoneApi/PhoneApi.csproj'
# dotnet run biên dịch nếu cần rồi chạy API. Hồ sơ http trong launchSettings.json lắng nghe cổng 5000.
# Máy tính gọi localhost:5000; Android Emulator gọi 10.0.2.2:5000; giữ terminal mở và dừng bằng Ctrl+C.
& dotnet run --project $project --launch-profile http
# Báo lỗi nếu tiến trình dotnet kết thúc không thành công, ví dụ thiếu cấu hình hoặc cổng đang bị chiếm.
if ($LASTEXITCODE -ne 0) { throw 'API đã dừng với lỗi.' }
