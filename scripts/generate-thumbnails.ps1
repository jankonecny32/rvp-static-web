# Generate thumbnail images for the gallery.
# Creates a "thumbs" subfolder in img/rvp/galerie/ with resized images (max 800px width).
# Uses System.Drawing which is built into Windows - no extra tools needed.
#
# Usage: pwsh scripts/generate-thumbnails.ps1

Add-Type -AssemblyName System.Drawing

$galleryDir = Join-Path $PSScriptRoot ".." "img" "rvp" "galerie"
$maxWidth = 800
$quality = 80
$imageExtensions = @(".jpg", ".jpeg", ".png")

# JPEG encoder and quality parameter
$jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
$qualityParam = New-Object System.Drawing.Imaging.EncoderParameters(1)
$qualityParam.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]$quality)

$totalProcessed = 0

if (-not (Test-Path $galleryDir)) {
    Write-Host "Gallery directory not found: $galleryDir"
    exit 1
}

$thumbsDir = Join-Path $galleryDir "thumbs"
if (-not (Test-Path $thumbsDir)) {
    New-Item -ItemType Directory -Path $thumbsDir -Force | Out-Null
}

$files = Get-ChildItem -Path $galleryDir -File | Where-Object { $imageExtensions -contains $_.Extension.ToLower() }

foreach ($file in $files) {
    $thumbPath = Join-Path $thumbsDir $file.Name
    
    # Skip if thumb already exists and is newer than source
    if ((Test-Path $thumbPath) -and (Get-Item $thumbPath).LastWriteTime -ge $file.LastWriteTime) {
        continue
    }

    try {
        $img = [System.Drawing.Image]::FromFile($file.FullName)

        # Apply EXIF orientation so thumbnails are not rotated
        try {
            $orientationId = 0x0112
            if ($img.PropertyIdList -contains $orientationId) {
                $orientation = $img.GetPropertyItem($orientationId).Value[0]
                switch ($orientation) {
                    2 { $img.RotateFlip([System.Drawing.RotateFlipType]::RotateNoneFlipX) }
                    3 { $img.RotateFlip([System.Drawing.RotateFlipType]::Rotate180FlipNone) }
                    4 { $img.RotateFlip([System.Drawing.RotateFlipType]::RotateNoneFlipY) }
                    5 { $img.RotateFlip([System.Drawing.RotateFlipType]::Rotate270FlipX) }
                    6 { $img.RotateFlip([System.Drawing.RotateFlipType]::Rotate90FlipNone) }
                    7 { $img.RotateFlip([System.Drawing.RotateFlipType]::Rotate90FlipX) }
                    8 { $img.RotateFlip([System.Drawing.RotateFlipType]::Rotate270FlipNone) }
                }
                $img.RemovePropertyItem($orientationId)
            }
        } catch { }

        if ($img.Width -le $maxWidth) {
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

Write-Host "`nDone! Processed $totalProcessed thumbnails."
