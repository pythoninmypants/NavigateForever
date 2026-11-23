# Build the CurseForge zip and a 512x512 project logo.
# The zip root is the NavigateForever folder, which is what the uploader expects.

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$tocPath = Join-Path $root "NavigateForever.toc"
$toc = Get-Content -Raw -Path $tocPath
$version = [regex]::Match($toc, "(?m)^## Version:\s*(\S+)").Groups[1].Value
if (-not $version) { throw "NavigateForever.toc has no ## Version line." }

$dist = Join-Path $root "dist"
New-Item -ItemType Directory -Force -Path $dist | Out-Null
$zipPath = Join-Path $dist "NavigateForever-$version.zip"
$logoPath = Join-Path $dist "curseforge-logo.png"

$files = @(
    "NavigateForever.toc",
    "NavigateForever.lua",
    "NavigateForeverPlaces.lua",
    "NavigateForeverArrow.lua",
    "NavigateForeverUses.lua",
    "NavigateForeverBobber.lua",
    "NavigateForeverNodes.lua",
    "NavigateForeverTrail.lua",
    "NavigateForeverBoats.lua",
    "NavigateForeverHUD.lua",
    "Bindings.xml",
    "Media\hud-mask.tga",
    "README.md",
    "CHANGELOG.md",
    "LICENSE",
    "Media\icon.tga",
    "Media\arrow-nav.tga",
    "Media\theme-undead-logo.tga",
    "Media\theme-undead-corner.tga",
    "Media\theme-horde-logo.tga",
    "Media\theme-horde-corner.tga",
    "Media\theme-alliance-logo.tga",
    "Media\theme-alliance-corner.tga",
    "Media\theme-nightelf-logo.tga",
    "Media\theme-nightelf-corner.tga",
    "Media\theme-arcane-logo.tga",
    "Media\theme-arcane-corner.tga",
    "Media\theme-frost-logo.tga",
    "Media\theme-frost-corner.tga",
    "Media\theme-fire-logo.tga",
    "Media\theme-fire-corner.tga",
    "Media\theme-warrior-logo.tga",
    "Media\theme-warrior-corner.tga",
    "Media\theme-paladin-logo.tga",
    "Media\theme-paladin-corner.tga",
    "Media\theme-hunter-logo.tga",
    "Media\theme-hunter-corner.tga",
    "Media\theme-rogue-logo.tga",
    "Media\theme-rogue-corner.tga",
    "Media\theme-priest-logo.tga",
    "Media\theme-priest-corner.tga",
    "Media\theme-shaman-logo.tga",
    "Media\theme-shaman-corner.tga",
    "Media\theme-mage-logo.tga",
    "Media\theme-mage-corner.tga",
    "Media\theme-warlock-logo.tga",
    "Media\theme-warlock-corner.tga",
    "Media\theme-druid-logo.tga",
    "Media\theme-druid-corner.tga",
    "Media\theme-kitty-logo.tga",
    "Media\theme-kitty-corner.tga",
    "Media\theme-kitty-bottom.tga",
    "Media\theme-blizzard-logo.tga",
    "Media\theme-blizzard-corner.tga",
    "Media\theme-human-logo.tga",
    "Media\theme-human-corner.tga",
    "Media\theme-dwarf-logo.tga",
    "Media\theme-dwarf-corner.tga",
    "Media\theme-gnome-logo.tga",
    "Media\theme-gnome-corner.tga",
    "Media\theme-orc-logo.tga",
    "Media\theme-orc-corner.tga",
    "Media\theme-troll-logo.tga",
    "Media\theme-troll-corner.tga",
    "Media\theme-tauren-logo.tga",
    "Media\theme-tauren-corner.tga",
    "Media\theme-skyborne-logo.tga",
    "Media\theme-skyborne-corner.tga",
    "Media\theme-hallowsend-logo.tga",
    "Media\theme-hallowsend-corner.tga",
    "Media\theme-winterveil-logo.tga",
    "Media\theme-winterveil-corner.tga",
    "Media\theme-lunarfestival-logo.tga",
    "Media\theme-lunarfestival-corner.tga",
    "Media\theme-loveintheair-logo.tga",
    "Media\theme-loveintheair-corner.tga",
    "Media\theme-mist.tga",
    "Media\theme-flame.tga",
    "Media\theme-spark.tga",
    "Media\theme-star.tga",
    "Media\theme-snow.tga",
    "Media\theme-leaf.tga",
    "Media\theme-feather.tga",
    "Media\theme-bubble.tga",
    "Media\theme-heart.tga",
    "Media\theme-paw.tga",
    "Media\theme-bat.tga",
    "Media\theme-gear.tga",
    "Media\theme-cat.tga"
)
foreach ($rel in $files) {
    $path = Join-Path $root $rel
    if (-not (Test-Path -LiteralPath $path)) { throw "Missing $rel" }
}

if (Test-Path -LiteralPath $zipPath) { Remove-Item -LiteralPath $zipPath }
$zip = [System.IO.Compression.ZipFile]::Open($zipPath, [System.IO.Compression.ZipArchiveMode]::Create)
try {
    foreach ($rel in $files) {
        $entry = ("NavigateForever/" + ($rel -replace "\\", "/"))
        [void][System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
            $zip,
            (Join-Path $root $rel),
            $entry,
            [System.IO.Compression.CompressionLevel]::Optimal
        )
    }
}
finally {
    $zip.Dispose()
}

$masterLogo = Join-Path $root "art\curseforge-logo.png"
if (Test-Path -LiteralPath $masterLogo) {
    Copy-Item -LiteralPath $masterLogo -Destination $logoPath -Force
} else {
    $tga = [System.IO.File]::ReadAllBytes((Join-Path $root "Media\icon.tga"))
    $width = [BitConverter]::ToUInt16($tga, 12)
    $height = [BitConverter]::ToUInt16($tga, 14)
    $bpp = $tga[16]
    $topDown = ($tga[17] -band 0x20) -ne 0
    if ($tga[2] -ne 2 -or $bpp -ne 32) { throw "Media\icon.tga is not a 32-bit uncompressed image." }

    $src = New-Object System.Drawing.Bitmap $width, $height, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $rect = New-Object System.Drawing.Rectangle 0, 0, $width, $height
    $bits = $src.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::WriteOnly, $src.PixelFormat)
    try {
        for ($y = 0; $y -lt $height; $y++) {
            $destY = if ($topDown) { $y } else { $height - 1 - $y }
            $dest = [IntPtr]::Add($bits.Scan0, $destY * $bits.Stride)
            [System.Runtime.InteropServices.Marshal]::Copy($tga, 18 + ($y * $width * 4), $dest, $width * 4)
        }
    }
    finally {
        $src.UnlockBits($bits)
    }

    $logo = New-Object System.Drawing.Bitmap 512, 512, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($logo)
    try {
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
        $graphics.DrawImage($src, (New-Object System.Drawing.Rectangle 0, 0, 512, 512))
    }
    finally {
        $graphics.Dispose()
        $src.Dispose()
    }
    $logo.Save($logoPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $logo.Dispose()
}

$check = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
try {
    $names = @($check.Entries | ForEach-Object { $_.FullName })
}
finally {
    $check.Dispose()
}

Write-Output "Zip: $zipPath"
Write-Output "Logo: $logoPath"
$names | ForEach-Object { Write-Output "  $_" }
$bad = @($names | Where-Object { $_ -notmatch "^NavigateForever/" -or $_ -match "\\" })
if ($bad.Count -gt 0) { throw "Zip layout is wrong: $($bad -join ', ')" }
if ($names -notcontains "NavigateForever/NavigateForever.toc") { throw "Zip is missing the TOC." }
Write-Output "Layout ok. $version entries: $($names.Count)"
