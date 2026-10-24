// Điểm khởi động và cấu hình của API điện thoại.
// Luồng chính: Flutter gửi HTTP → PhonesController → AppDbContext → SQL Server → JSON trả về Flutter.
// Ảnh đi theo luồng riêng: Flutter gọi /images/... → đọc tệp trong wwwroot/images.
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.EntityFrameworkCore;
using PhoneApi.Data;
using PhoneApi.DTOs;

// Tạo bộ cấu hình, hệ thống ghi log và nơi đăng ký các dịch vụ dùng trong ứng dụng.
var builder = WebApplication.CreateBuilder(args);
// Đọc cấu hình riêng của máy; appsettings.Local.json có chuỗi kết nối thật nên được .gitignore loại trừ.
// Biến môi trường được thêm sau cùng nên có thể ghi đè cấu hình tệp khi chạy trên máy khác.
builder.Configuration.AddJsonFile("appsettings.Local.json", optional: true, reloadOnChange: false)
    .AddEnvironmentVariables();
// Đọc ConnectionStrings:PhoneStore. Đây là tên cấu hình kết nối, không phải tên bảng.
// Dừng sớm nếu thiếu cấu hình để người chạy biết cần thực hiện Configure-Local.ps1.
var connectionString = builder.Configuration.GetConnectionString("PhoneStore");
if (string.IsNullOrWhiteSpace(connectionString))
    throw new InvalidOperationException("Chưa cấu hình CSDL. Chạy scripts/Configure-Local.ps1 trước.");

// Đăng ký AppDbContext vào cơ chế cấp đối tượng tự động của ASP.NET Core.
// UseSqlServer chọn bộ kết nối EF Core dành cho SQL Server; mỗi yêu cầu HTTP dùng một DbContext theo phạm vi yêu cầu.
// Bảng đã được tạo bằng script SQL; chương trình không gọi EnsureCreated hoặc tự chạy migration.
builder.Services.AddDbContext<AppDbContext>(options => options.UseSqlServer(connectionString));
// Đăng ký hỗ trợ Controller và chuyển đối tượng C# thành JSON.
// Cấu hình mặc định cho web dùng camelCase: Id thành id, ImageUrl thành imageUrl, đúng giao kèo với Sơn.
builder.Services.AddControllers();
// CORS chỉ liên quan giới hạn truy cập khác nguồn của trình duyệt, ví dụ Flutter chạy trên Chrome.
// Ứng dụng Android không cần CORS; danh sách mặc định rỗng nên không tự cho phép mọi website.
// Nếu chạy web, chỉ cho các nguồn đã khai báo thực hiện GET; AllowAnyHeader không có nghĩa cho mọi nguồn truy cập.
var webOrigins = builder.Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>() ?? [];
builder.Services.AddCors(options => options.AddPolicy("FlutterWeb", policy =>
{
    if (webOrigins.Length > 0)
        policy.WithOrigins(webOrigins).WithMethods("GET").AllowAnyHeader();
}));
// Tạo ứng dụng từ các dịch vụ đã đăng ký; các lệnh Use/Map phía sau thiết lập cách xử lý yêu cầu.
var app = builder.Build();
// Bắt ngoại lệ chưa được xử lý ở các bước phía sau, kể cả lỗi truy vấn SQL.
// Chi tiết lỗi được ghi ở máy chủ để kiểm tra; phía Flutter chỉ nhận HTTP 500 và JSON thông báo chung.
// Đặt bước này trước xử lý ảnh và Controller để bao được các lỗi phát sinh phía sau.
app.UseExceptionHandler(errorApp => errorApp.Run(async context =>
{
    var error = context.Features.Get<IExceptionHandlerFeature>()?.Error;
    app.Logger.LogError(error, "Không thể xử lý yêu cầu {Path}", context.Request.Path);
    context.Response.StatusCode = StatusCodes.Status500InternalServerError;
    await context.Response.WriteAsJsonAsync(new ApiError("INTERNAL_ERROR", "Không thể tải dữ liệu. Vui lòng thử lại sau."));
}));
// Áp dụng chính sách CORS đã đăng ký cho các yêu cầu phù hợp.
app.UseCors("FlutterWeb");
// Cho phép tải tệp công khai trong wwwroot: /images/iphone15.jpg trỏ tới wwwroot/images/iphone15.jpg.
// Tệp cấu hình kết nối nằm ngoài wwwroot nên không được phục vụ bằng đường dẫn ảnh này.
app.UseStaticFiles();
// Ánh xạ các đường dẫn khai báo bằng Route/HttpGet trong Controller vào hệ thống xử lý HTTP.
app.MapControllers();
// Đường dẫn gốc chỉ giới thiệu API để kiểm tra máy chủ đang chạy; không dùng thay endpoint lấy điện thoại.
app.MapGet("/", () => Results.Ok(new { name = "Phone API", endpoints = new[] { "/api/phones", "/api/phones/{id}" } }));
// Bắt đầu lắng nghe yêu cầu. Cổng và địa chỉ khi chạy bằng script lấy từ hồ sơ http trong launchSettings.json.
app.Run();
