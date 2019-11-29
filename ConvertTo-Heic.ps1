# ConvertTo-Heic - Converts image files to the efficient HEIC format
# https://github.com/DavidAnson/ConvertTo-Heic

Param (
    [Parameter(
        Mandatory = $true,
        Position = 1,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true,
        ValueFromRemainingArguments = $true,
        HelpMessage = "Array of image file names to convert to HEIC")]
    [Alias("FullName")]
    [String[]]
    $Files
)

Begin
{
    # Technique for await-ing WinRT APIs: https://fleexlab.blogspot.com/2018/02/using-winrts-iasyncoperation-in.html
    Add-Type -AssemblyName System.Runtime.WindowsRuntime
    $runtimeMethods = [System.WindowsRuntimeSystemExtensions].GetMethods()
    $asTaskGeneric = ($runtimeMethods | ? { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' })[0]
    Function AwaitOperation ($WinRtTask, $ResultType)
    {
        $asTaskSpecific = $asTaskGeneric.MakeGenericMethod($ResultType)
        $netTask = $asTaskSpecific.Invoke($null, @($WinRtTask))
        $netTask.Wait() | Out-Null
        $netTask.Result
    }
    $asTask = ($runtimeMethods | ? { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncAction' })[0]
    Function AwaitAction ($WinRtTask)
    {
        $netTask = $asTask.Invoke($null, @($WinRtTask))
        $netTask.Wait() | Out-Null
    }

    # Reference WinRT assemblies
    [Windows.Storage.StorageFile, Windows.Storage, ContentType=WindowsRuntime] | Out-Null
    [Windows.Graphics.Imaging.BitmapDecoder, Windows.Graphics, ContentType=WindowsRuntime] | Out-Null
}

Process
{
    # Check dependencies
    if (([Windows.Graphics.Imaging.BitmapEncoder]::HeifEncoderId -eq $null) -or ([Windows.Graphics.Imaging.BitmapDecoder]::HeifDecoderId -eq $null))
    {
        Write-Error "HEIC encoder/decoder not present. Please see README.md for more information."
        Exit
    }

    # Summary of imaging APIs: https://docs.microsoft.com/en-us/windows/uwp/audio-video-camera/imaging
    foreach ($file in $Files)
    {
        Write-Host $file -NoNewline
        try
        {
            try
            {
                # Get SoftwareBitmap from input file
                $file = Resolve-Path -LiteralPath $file
                $inputFile = AwaitOperation ([Windows.Storage.StorageFile]::GetFileFromPathAsync($file)) ([Windows.Storage.StorageFile])
                $inputFolder = AwaitOperation ($inputFile.GetParentAsync()) ([Windows.Storage.StorageFolder])
                $inputStream = AwaitOperation ($inputFile.OpenReadAsync()) ([Windows.Storage.Streams.IRandomAccessStreamWithContentType])
                $decoder = AwaitOperation ([Windows.Graphics.Imaging.BitmapDecoder]::CreateAsync($inputStream)) ([Windows.Graphics.Imaging.BitmapDecoder])
            }
            catch
            {
                # Ignore non-image files
                Write-Host " [Unsupported]"
                continue
            }
            if ($decoder.DecoderInformation.CodecId -eq [Windows.Graphics.Imaging.BitmapDecoder]::HeifDecoderId)
            {
                # Skip HEIC-encoded files
                Write-Host " [Already HEIC]"
                continue
            }
            $bitmap = AwaitOperation ($decoder.GetSoftwareBitmapAsync()) ([Windows.Graphics.Imaging.SoftwareBitmap])

            # Write SoftwareBitmap to output file
            $outputFileName = $inputFile.Name + ".heic";
            $outputFile = AwaitOperation ($inputFolder.CreateFileAsync($outputFileName, [Windows.Storage.CreationCollisionOption]::ReplaceExisting)) ([Windows.Storage.StorageFile])
            $outputStream = AwaitOperation ($outputFile.OpenAsync([Windows.Storage.FileAccessMode]::ReadWrite)) ([Windows.Storage.Streams.IRandomAccessStream])
            $encoder = AwaitOperation ([Windows.Graphics.Imaging.BitmapEncoder]::CreateAsync([Windows.Graphics.Imaging.BitmapEncoder]::HeifEncoderId, $outputStream)) ([Windows.Graphics.Imaging.BitmapEncoder])
            $encoder.SetSoftwareBitmap($bitmap)
            $encoder.IsThumbnailGenerated = $true

            # Do it
            AwaitAction ($encoder.FlushAsync())
            Write-Host " -> $outputFileName"
        }
        catch
        {
            # Report full details
            throw $_.Exception.ToString()
        }
        finally
        {
            # Clean-up
            if ($inputStream -ne $null) { [System.IDisposable]$inputStream.Dispose() }
            if ($outputStream -ne $null) { [System.IDisposable]$outputStream.Dispose() }
        }
    }
}
