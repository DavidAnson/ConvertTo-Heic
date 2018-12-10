# ConvertTo-Heic

> A PowerShell script that converts image files to the efficient HEIC format

## Overview

The [JPEG image file format](https://en.wikipedia.org/wiki/JPEG) is universally supported and a great way to store images.
However, it is no longer the most space-efficient way to do so.
The [High Efficiency Image File format](https://en.wikipedia.org/wiki/High_Efficiency_Image_File_Format) used by HEIC/HEIF images maintains the same quality as JPEG in roughly half the space.

`ConvertTo-Heic.ps1` is a [PowerShell](https://en.wikipedia.org/wiki/PowerShell) script that uses the [Windows.Graphics.Imaging API](https://docs.microsoft.com/en-us/uwp/api/windows.graphics.imaging) to create a HEIC-encoded copy of each image that is passed to it.
(The original file is not modified.)

## Related

- [ConvertTo-Jpeg.ps1](https://github.com/DavidAnson/ConvertTo-Jpeg): A PowerShell script that converts RAW (and other) image files to the widely-supported JPEG format

## Requirements

Windows 10's April 2018 Update (version 1803) introduced support for reading HEIC/HEIF images to the Windows.Graphics.Imaging API.
Windows 10's October 2018 Update (version 1809) improved support for HEIC/HEIF images, making it possible to write them.
`ConvertTo-Heic.ps1` requires the October 2018 Update (version 1809).
To enable the encoder, install the Microsoft [HEIF and HEVC Media Extensions](https://www.microsoft.com/store/productId/9NTLD6MSD8BM) bundle (or else both of [HEVC Video Extensions](https://www.microsoft.com/store/productId/9NMZLZ57R3T7) and [HEIF Image Extensions](https://www.microsoft.com/store/productId/9PMMSR1CGPWG)).
Once done, the built-in Photos app (and other programs that use the Windows.Graphics.Imaging API) will be able to work with HEIC/HEIF images.

## Examples

### Converting Files

Passing parameters:

```PowerShell
PS C:\T> .\ConvertTo-Heic.ps1 C:\T\Pictures\IMG_1234.BMP C:\T\Pictures\IMG_5678.CR2
C:\T\Pictures\IMG_1234.BMP -> IMG_1234.BMP.heic
C:\T\Pictures\IMG_5678.CR2 -> IMG_5678.CR2.heic
```

Pipeline via `dir`:

```PowerShell
PS C:\T> dir C:\T\Pictures | .\ConvertTo-Heic.ps1
C:\T\Pictures\IMG_1234.BMP -> IMG_1234.BMP.heic
C:\T\Pictures\IMG_5678.CR2 -> IMG_5678.CR2.heic
C:\T\Pictures\Kitten.heic [Already HEIC]
C:\T\Pictures\Notes.txt [Unsupported]
```

Pipeline via `Get-ChildItem`:

```PowerShell
PS C:\T> Get-ChildItem C:\T\Pictures -Filter *.BMP | .\ConvertTo-Heic.ps1
C:\T\Pictures\IMG_1234.BMP -> IMG_1234.BMP.heic
```

## Formats

| Decoder                      | Extensions |
| ---------------------------- | ---------- |
| BMP Decoder                  | .BMP .DIB .RLE |
| CUR Decoder                  | .CUR |
| DDS Decoder                  | .DDS |
| DNG Decoder                  | .DNG |
| GIF Decoder                  | .GIF |
| ICO Decoder                  | .ICO .ICON |
| JPEG Decoder                 | .EXIF .JFIF .JPE .JPEG .JPG |
| Microsoft Camera Raw Decoder | .ARW .CR2 .CRW .DNG .ERF .KDC .MRW .NEF .NRW .ORF .PEF .RAF .RAW .RW2 .RWL .SR2 .SRW |
| Microsoft HEIF Decoder       | .AVCI .AVCS .HEIC .HEICS .HEIF .HEIFS |
| Microsoft Webp Decoder       | .WEBP |
| PNG Decoder                  | .PNG |
| TIFF Decoder                 | .TIF .TIFF |
| WMPhoto Decoder              | .JXR .WDP |
