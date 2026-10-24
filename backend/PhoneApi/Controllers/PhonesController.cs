using System.Globalization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PhoneApi.Data;
using PhoneApi.DTOs;
using PhoneApi.Models;

namespace PhoneApi.Controllers;

[ApiController]
[Route("api/phones")]
public sealed class PhonesController(AppDbContext db) : ControllerBase
{
    [HttpGet]
    [ProducesResponseType<List<PhoneDto>>(StatusCodes.Status200OK)]
    public async Task<ActionResult<List<PhoneDto>>> GetAll(CancellationToken cancellationToken)
    {
        var phones = await db.Phones.AsNoTracking().OrderBy(p => p.Id).ToListAsync(cancellationToken);
        return Ok(phones.Select(ToDto).ToList());
    }

    // Keep id as string: non-numeric and out-of-range ids also return our JSON 400.
    [HttpGet("{id}")]
    [ProducesResponseType<PhoneDto>(StatusCodes.Status200OK)]
    [ProducesResponseType<ApiError>(StatusCodes.Status400BadRequest)]
    [ProducesResponseType<ApiError>(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<PhoneDto>> GetById(string id, CancellationToken cancellationToken)
    {
        if (!int.TryParse(id, NumberStyles.None, CultureInfo.InvariantCulture, out var phoneId) || phoneId <= 0)
            return BadRequest(new ApiError("INVALID_ID", "Mã điện thoại phải là số nguyên dương."));

        var phone = await db.Phones.AsNoTracking().SingleOrDefaultAsync(p => p.Id == phoneId, cancellationToken);
        return phone is null
            ? NotFound(new ApiError("PHONE_NOT_FOUND", "Không tìm thấy điện thoại."))
            : Ok(ToDto(phone));
    }

    private PhoneDto ToDto(Phone phone)
    {
        // Use the caller's host: localhost for PC, 10.0.2.2 for Android Emulator.
        var imageUrl = $"{Request.Scheme}://{Request.Host}{Request.PathBase}{phone.ImagePath}";
        return new PhoneDto(phone.Id, phone.Name, phone.Price, imageUrl, phone.Description);
    }
}
