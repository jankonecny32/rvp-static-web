# Generate thumbnail images for the gallery.
# Creates a "thumbs" subfolder in each category with resized images (max 800px width).
# Uses System.Drawing which is built into Windows - no extra tools needed.
#
# Usage: pwsh scripts/generate-thumbnails.ps1

Add-Type -AssemblyName System.Drawing

$galleryDir = Join-Path $PSScriptRoot ".." "img" "rvp"
$maxWidth = 800
$quality = 80
$imageExtensions = @(".jpg", ".jpeg", ".png")

$categories = @(
    "tesarske-prace",
    "stavebni-prace",
    "fasadni-panely",
    "pro-vase-projekty"
)

# JPEG encoder and quality parameter
$jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
$qualityParam = New-Object System.Drawing.Imaging.EncoderParameters(1)
$qualityParam.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]$quality)

$totalProcessed = 0

foreach ($category in $categories) {
    $categoryPath = Join-Path $galleryDir $category
    if (-not (Test-Path $categoryPath)) { continue }

    $thumbsDir = Join-Path $categoryPath "thumbs"
    if (-not (Test-Path $thumbsDir)) {
        New-Item -ItemType Directory -Path $thumbsDir -Force | Out-Null
    }

    $files = Get-ChildItem -Path $categoryPath -File | Where-Object { $imageExtensions -contains $_.Extension.ToLower() }

    foreach ($file in $files) {
        $thumbPath = Join-Path $thumbsDir $file.Name
        
        # Skip if thumb already exists and is newer than source
        if ((Test-Path $thumbPath) -and (Get-Item $thumbPath).LastWriteTime -ge $file.LastWriteTime) {
            continue
        }

        try {
            $img = [System.Drawing.Image]::FromFile($file.FullName)
            
            if ($img.Width -le $maxWidth) {
                # Image is already small enough, just copy with compression
                $newWidth = $img.Width
                $newHeight = $img.Height
            } else {
                $ratio = $maxWidth / $img.Width
                $newWidth = $maxWidth
                $newHeight = [int]($img.Height * $ratio)
            }

            $thumb = New-Object System.Drawing.Bitmap($newWidth, $newHeight)
            $graphics = [System.Drawing.Graphics]::FromImage($thumb)
            $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
            $graphics.DrawImage($img, 0, 0, $newWidth, $newHeight)

            $thumb.Save($thumbPath, $jpegCodec, $qualityParam)

            $graphics.Dispose()
            $thumb.Dispose()
            $img.Dispose()

            $originalKB = [math]::Round($file.Length / 1KB)
            $thumbKB = [math]::Round((Get-Item $thumbPath).Length / 1KB)
            Write-Host "  $($file.Name): ${originalKB}KB -> ${thumbKB}KB ($newWidth x $newHeight)"
            $totalProcessed++
        } catch {
            Write-Warning "Failed to process $($file.Name): $_"
        }
    }
}

Write-Host "`nDone! Processed $totalProcessed thumbnails."
