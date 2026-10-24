param(
    [string]$Directory = (Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'Codex/BuildCache/BaiTapNhom_DiDong')
)
$ErrorActionPreference = 'Stop'
$repo = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$build = Join-Path $repo 'build'
$target = [IO.Path]::GetFullPath($Directory)
# Đích phải nằm ngoài project, tránh tạo vòng lặp hoặc đặt build đè lên mã nguồn.
if ($target -eq $repo -or $target.StartsWith($repo + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Thư mục build đích phải nằm ngoài project.'
}
if (Test-Path -LiteralPath $build) {
    $item = Get-Item -LiteralPath $build -Force
    if ($item.LinkType -eq 'Junction' -and [IO.Path]::GetFullPath([string]$item.Target) -eq $target) {
        Write-Host "Build đã được chuyển tới $target"
        return
    }
    throw 'Thư mục build đã tồn tại. Chạy flutter clean để xóa kết quả sinh tự động, rồi chạy lại script.'
}
New-Item -ItemType Directory -Path $target -Force | Out-Null
# Junction chuyển phần ghi tệp build sang ổ còn chỗ; Flutter/Gradle vẫn thấy đường dẫn project/build.
# Đây là thiết lập riêng trên máy, không được commit; mã nguồn vẫn ở vị trí cũ.
New-Item -ItemType Junction -Path $build -Target $target | Out-Null
Write-Host "Kết quả build sẽ được ghi vào $target"
