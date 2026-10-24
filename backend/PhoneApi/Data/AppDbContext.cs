// Lớp trung gian giữa các đối tượng C# và SQL Server, kế thừa DbContext của EF Core.
// Thiết kế theo CSDL tạo trước bằng database/schema.sql; các ánh xạ dưới đây được viết tường minh theo bảng đó.
using Microsoft.EntityFrameworkCore;
using PhoneApi.Models;

namespace PhoneApi.Data;

// Nhận options đã được cấu hình UseSqlServer trong Program.cs; không viết mật khẩu trực tiếp trong lớp này.
public sealed class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    // DbSet<Phone> là điểm bắt đầu truy vấn bảng điện thoại; khai báo này không có nghĩa đã tải mọi bản ghi vào bộ nhớ.
    public DbSet<Phone> Phones => Set<Phone>();

    // Khai báo cách ánh xạ lớp và thuộc tính sang bảng/cột, bổ sung chi tiết mà EF không thể suy ra đầy đủ.
    // Các cấu hình này mô tả mô hình; bản thân hàm không tạo bảng hay ràng buộc trong DB đang chạy.
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Phone>(entity =>
        {
            // Ánh xạ Phone vào bảng dbo.Phones. Hai CHECK phải khớp ràng buộc đã tạo trong schema.sql:
            // giá không âm và tên không được rỗng hoặc chỉ gồm khoảng trắng.
            entity.ToTable("Phones", "dbo", table =>
            {
                table.HasCheckConstraint("CK_Phones_Price", "[Price] >= 0");
                table.HasCheckConstraint("CK_Phones_Name", "LEN(LTRIM(RTRIM([Name]))) > 0");
            });
            // Id là khóa chính; SQL Server sinh giá trị bằng IDENTITY khi thêm dữ liệu thông thường.
            entity.HasKey(phone => phone.Id);
            entity.Property(phone => phone.Id).UseIdentityColumn();
            // Chuỗi tên là Unicode theo quy ước SQL Server của EF, tối đa 150 ký tự và không được NULL.
            // IsRequired không thay CHECK tên trống; hai ràng buộc giải quyết hai trường hợp khác nhau.
            entity.Property(phone => phone.Name).HasMaxLength(150).IsRequired();
            // decimal(18,0) lưu tối đa 18 chữ số, không có phần thập phân, phù hợp giá VND trong bài thực hành.
            entity.Property(phone => phone.Price).HasColumnType("decimal(18,0)");
            // Chỉ lưu đường dẫn ảnh, tối đa 500 ký tự; tệp ảnh thật được đặt trong wwwroot/images.
            entity.Property(phone => phone.ImagePath).HasMaxLength(500).IsRequired();
            // Mô tả bắt buộc có giá trị khác NULL; không đặt độ dài tối đa nên ánh xạ về NVARCHAR(MAX).
            entity.Property(phone => phone.Description).IsRequired();
        });
    }
}
