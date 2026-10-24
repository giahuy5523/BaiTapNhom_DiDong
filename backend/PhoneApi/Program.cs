using Microsoft.AspNetCore.Diagnostics;
using Microsoft.EntityFrameworkCore;
using PhoneApi.Data;
using PhoneApi.DTOs;

var builder = WebApplication.CreateBuilder(args);
// Local settings are ignored by Git. Environment variables take priority.
builder.Configuration.AddJsonFile("appsettings.Local.json", optional: true, reloadOnChange: false)
    .AddEnvironmentVariables();
var connectionString = builder.Configuration.GetConnectionString("PhoneStore");
if (string.IsNullOrWhiteSpace(connectionString))
    throw new InvalidOperationException("Chưa cấu hình CSDL. Chạy scripts/Configure-Local.ps1 trước.");

builder.Services.AddDbContext<AppDbContext>(options => options.UseSqlServer(connectionString));
builder.Services.AddControllers();
var webOrigins = builder.Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>() ?? [];
builder.Services.AddCors(options => options.AddPolicy("FlutterWeb", policy =>
{
    if (webOrigins.Length > 0)
        policy.WithOrigins(webOrigins).WithMethods("GET").AllowAnyHeader();
}));
var app = builder.Build();
app.UseExceptionHandler(errorApp => errorApp.Run(async context =>
{
    var error = context.Features.Get<IExceptionHandlerFeature>()?.Error;
    app.Logger.LogError(error, "Không thể xử lý yêu cầu {Path}", context.Request.Path);
    context.Response.StatusCode = StatusCodes.Status500InternalServerError;
    await context.Response.WriteAsJsonAsync(new ApiError("INTERNAL_ERROR", "Không thể tải dữ liệu. Vui lòng thử lại sau."));
}));
app.UseCors("FlutterWeb");
app.UseStaticFiles();
app.MapControllers();
app.MapGet("/", () => Results.Ok(new { name = "Phone API", endpoints = new[] { "/api/phones", "/api/phones/{id}" } }));
app.Run();
