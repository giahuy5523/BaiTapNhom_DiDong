using Microsoft.EntityFrameworkCore;
using PhoneApi.Models;

namespace PhoneApi.Data;

// Database First: database/schema.sql is the schema source of truth.
public sealed class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<Phone> Phones => Set<Phone>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Phone>(entity =>
        {
            entity.ToTable("Phones", "dbo", table =>
            {
                table.HasCheckConstraint("CK_Phones_Price", "[Price] >= 0");
                table.HasCheckConstraint("CK_Phones_Name", "LEN(LTRIM(RTRIM([Name]))) > 0");
            });
            entity.HasKey(phone => phone.Id);
            entity.Property(phone => phone.Id).UseIdentityColumn();
            entity.Property(phone => phone.Name).HasMaxLength(150).IsRequired();
            entity.Property(phone => phone.Price).HasColumnType("decimal(18,0)");
            entity.Property(phone => phone.ImagePath).HasMaxLength(500).IsRequired();
            entity.Property(phone => phone.Description).IsRequired();
        });
    }
}
