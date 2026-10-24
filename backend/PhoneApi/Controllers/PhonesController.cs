// Nhận yêu cầu lấy danh sách hoặc chi tiết điện thoại; không chứa giao diện Flutter.
// Controller đọc dữ liệu qua EF Core, chuyển sang DTO rồi trả mã HTTP và JSON cho ứng dụng.
using System.Globalization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PhoneApi.Data;
using PhoneApi.DTOs;
using PhoneApi.Models;

namespace PhoneApi.Controllers;

// Bật các quy ước dành cho API. ControllerBase cung cấp Ok, BadRequest và NotFound, không cần tạo trang HTML.
[ApiController]
// Đường dẫn chung của Controller: /api/phones. AppDbContext được truyền vào bằng cơ chế cấp đối tượng tự động.
// sealed chỉ ngăn kế thừa lớp; đây không phải cơ chế bảo mật hoặc đăng nhập.
[Route("api/phones")]
public sealed class PhonesController(AppDbContext db) : ControllerBase
{
    // GET /api/phones: lấy danh sách; endpoint này không thêm hoặc sửa dữ liệu.
    [HttpGet]
    // Khai báo kiểu phản hồi để mô tả API; thuộc tính này không tự thực hiện truy vấn hay quyết định mã HTTP.
    [ProducesResponseType<List<PhoneDto>>(StatusCodes.Status200OK)]
    // async/await chờ thao tác đọc DB mà không giữ luồng xử lý bị chặn trong lúc chờ.
    // CancellationToken truyền tín hiệu hủy, ví dụ khi bên gọi ngắt yêu cầu; không phải biến chứa dữ liệu điện thoại.
    public async Task<ActionResult<List<PhoneDto>>> GetAll(CancellationToken cancellationToken)
    {
        // AsNoTracking bỏ theo dõi thay đổi vì chức năng chỉ đọc; không cần tốn tài nguyên chuẩn bị cập nhật.
        // OrderBy cố định thứ tự theo Id; ToListAsync mới thực thi truy vấn và lấy dữ liệu từ SQL Server.
        // LINQ được EF Core dịch sang SQL, không phải tải toàn bộ dữ liệu rồi mới sắp xếp ở Flutter.
        var phones = await db.Phones.AsNoTracking().OrderBy(p => p.Id).ToListAsync(cancellationToken);
        // Chuyển từng bản ghi sang DTO và trả HTTP 200. Khi không có bản ghi, kết quả là [] theo giao kèo, không trả 404.
        return Ok(phones.Select(ToDto).ToList());
    }

    // GET /api/phones/{id}: lấy chi tiết theo khóa chính do dòng được chọn trên Flutter cung cấp.
    // Nhận id dạng string thay vì ràng buộc route {id:int} để cả abc và số vượt giới hạn đều có JSON lỗi 400 thống nhất.
    [HttpGet("{id}")]
    [ProducesResponseType<PhoneDto>(StatusCodes.Status200OK)]
    [ProducesResponseType<ApiError>(StatusCodes.Status400BadRequest)]
    [ProducesResponseType<ApiError>(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<PhoneDto>> GetById(string id, CancellationToken cancellationToken)
    {
        // Chỉ chấp nhận chuỗi chữ số biểu diễn số nguyên dương trong phạm vi Int32.
        // TryParse không ném ngoại lệ khi nhập sai; NumberStyles.None loại dấu, khoảng trắng và số thập phân.
        // Sai định dạng hoặc id ≤ 0 trả 400 vì đầu vào không hợp lệ, chưa cần hỏi DB.
        if (!int.TryParse(id, NumberStyles.None, CultureInfo.InvariantCulture, out var phoneId) || phoneId <= 0)
            return BadRequest(new ApiError("INVALID_ID", "Mã điện thoại phải là số nguyên dương."));

        // SingleOrDefaultAsync tìm theo khóa chính duy nhất: có thì trả Phone, không có thì trả null.
        // Điều kiện LINQ được dịch và tham số hóa bởi EF Core, không nối id vào chuỗi lệnh SQL.
        var phone = await db.Phones.AsNoTracking().SingleOrDefaultAsync(p => p.Id == phoneId, cancellationToken);
        // Id hợp lệ nhưng DB không có bản ghi thì trả 404; có bản ghi thì trả 200 cùng DTO chi tiết.
        return phone is null
            ? NotFound(new ApiError("PHONE_NOT_FOUND", "Không tìm thấy điện thoại."))
            : Ok(ToDto(phone));
    }

    // Hàm dùng chung cho danh sách và chi tiết để hai endpoint luôn trả cùng 5 trường.
    private PhoneDto ToDto(Phone phone)
    {
        // DB chỉ lưu ImagePath như /images/iphone15.jpg; Flutter cần URL đầy đủ để tải ảnh.
        // Ghép giao thức, host/cổng và đường dẫn gốc của yêu cầu: máy ảo gọi 10.0.2.2 thì URL ảnh cũng dùng 10.0.2.2.
        // Không ghi cứng localhost vì localhost trong máy ảo là chính máy ảo, không phải máy chạy API.
        var imageUrl = $"{Request.Scheme}://{Request.Host}{Request.PathBase}{phone.ImagePath}";
        return new PhoneDto(phone.Id, phone.Name, phone.Price, imageUrl, phone.Description);
    }
}
