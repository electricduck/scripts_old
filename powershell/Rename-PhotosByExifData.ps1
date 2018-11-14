  param (
    [Parameter(Mandatory=$true)][string]$Path,
    [bool]$IncludeDevice = $false,
    [bool]$IncludeOriginalName = $false,
    [bool]$IncludeProcessedTicks = $true,
    [string]$CustomDevice,
    [bool]$UseHashForSuffix = $false,
    [bool]$DryRun = $true,
    [bool]$KeepOriginal = $false,
    [bool]$ProcessVideos = $false,
    [string]$PhotoPrefix = "photo",
    [string]$VideoPrefix = "video",
    [int]$HashSuffixLength = 8
)

$cameraModelDictionary = @{}

$cameraModelDictionary.Add("iPhone4", "iPhone 4")                       # Apple iPhone 4
$cameraModelDictionary.Add("CanonEOS70D", "EOS 70D")                    # Canon EOS 70D
$cameraModelDictionary.Add("CanonEOS400DDIGITAL", "EOS 400D")           # Canon EOS 400D
$cameraModelDictionary.Add("CanonPowerShotA1300", "PowerShot A1300")    # Canon PowerShot A1300
$cameraModelDictionary.Add("HTCOne", "One M7")                          # HTC One / HTC One M7
$cameraModelDictionary.Add("HTCOne_M8", "One M8")                       # HTC One M8
$cameraModelDictionary.Add("NIKOND80", "D80")                           # Nikon D80
$cameraModelDictionary.Add("NIKOND5100", "D5100")                       # Nikon D1500
$cameraModelDictionary.Add("Lumia930", "Lumia 930")                     # Nokia Lumia 930
$cameraModelDictionary.Add("Lumia1320", "Lumia 1320")                   # Nokia Lumia 1320
$cameraModelDictionary.Add("VerneeMIX2", "MIX 2")                       # Vernee MIX 2
$cameraModelDictionary.Add("MiMax", "Mi Max")                           # Xiaomi Mi Max

function Get-CameraModelForPhoto {
    param (
        [Parameter(Mandatory=$true)][string]$File
    )

    $modelFromExif = (exiftool $File | Select-String "Camera Model Name").ToString().Replace("Camera Model Name", "").Replace(":","").Replace(" ","")
    $modelFromDictionary = $cameraModelDictionary.Item($modelFromExif)

    $modelFromDictionary
}

function Get-DateTakenForPhoto {
    param (
        [Parameter(Mandatory=$true)][string]$File
    )

    try {
        $dateFromExif = (exiftool $File | Select-String "Create Date")[0].ToString().Replace("Create Date", "").Replace(":","").Replace(" ","")
        if($DryRun -eq $false) {
            $dummy = exiftool -CreateDate="$dateFromExif" -DateTimeOriginal="$dateFromExif" -ModifyDate="$dateFromExif" -overwrite_original $File
        }
    } catch {
        try {
            $dateFromExif = (exiftool $File | Select-String "Modify Date")[0].ToString().Replace("Modify Date", "").Replace(":","").Replace(" ","")
            if($DryRun -eq $false) {
                $dummy = exiftool -CreateDate="$dateFromExif" -DateTimeOriginal="$dateFromExif" -ModifyDate="$dateFromExif" -overwrite_original $File
            }
        } catch {
            $dateFromExif = (exiftool $File | Select-String "Date/Time Original")[0].ToString().Replace("Date/Time Original", "").Replace(":","").Replace(" ","")
            if($DryRun -eq $false) {
                $dummy = exiftool -CreateDate="$dateFromExif" -DateTimeOriginal="$dateFromExif" -ModifyDate="$dateFromExif" -overwrite_original $File
            }
        }
    }

    $dateFromExif
}

function Get-DateTakenForVideo {
    param (
        [Parameter(Mandatory=$true)][string]$File
    )

    $dateFromExif = (exiftool $File | Select-String "Media Create Date")[0].ToString().Replace("Media Create Date", "").Replace(":","").Replace(" ","")

    $dateFromExif
}

function Get-Md5Hash {
    param (
        [Parameter(Mandatory=$true)][string]$File,
        [Parameter(Mandatory=$true)][int]$HashLength = 32
    )

    (Get-FileHash $File -Algorithm Md5).Hash.ToLower().Substring(0, $HashLength)
}

if($ProcessVideos) {
    $allFiles = Get-ChildItem -Path $Path | Where-Object {$_.Extension.ToLower() -in ".3gp",".mov",".mp4"}
} else {
    $allFiles = Get-ChildItem -Path $Path | Where-Object {$_.Extension.ToLower() -in ".jpg"}
}

foreach($file in $allFiles) {
    if($file.Extension.ToLower() -eq ".jpg") {
        $isPhoto = $true
    } else {
        $isPhoto = $false
    }

    if($file.Extension.ToLower() -eq ".jpg") {
        if($isPhoto) {
            $alreadyProcessedPrefix = $PhotoPrefix
        } else {
            $alreadyProcessedPrefix = "20"
        }
    } else {
        if($VideoPrefix) {
            $alreadyProcessedPrefix = $VideoPrefix
        } else {
            $alreadyProcessedPrefix = "20"
        }
    }

    $model = ""

    if($file.Name.StartsWith($alreadyProcessedPrefix) -eq $false) {
        if($isPhoto) {
            if($CustomDevice) {
                $model = $CustomDevice.Replace(" ", "")
            } else {
                $model = (Get-CameraModelForPhoto -File $file.FullName).Replace(" ", "")
            }
        }

        if($isPhoto) {
            $date = Get-DateTakenForPhoto -File $file.FullName
        } else {
            $date = Get-DateTakenForVideo -File $file.FullName
        }

        $originalDirectory = $file.DirectoryName + "/"
        $originalFilename = $file.BaseName
        $originalExtension = $file.Extension

        if($isPhoto) {
            $newFilename = $PhotoPrefix + "_"
        } else {
            $newFilename = $VideoPrefix + "_"
        }

        $newFilename += $date
        if($isPhoto) {
            if($IncludeDevice) { $newFilename += "." + $model }
        }
        if($IncludeOriginalName) { $newFilename += "." + $originalFilename }
        if($IncludeProcessedTicks) { 
            if($UseHashForSuffix) {
                $hash = Get-Md5Hash -File $file -HashLength $HashSuffixLength
                $newFilename += "_" + $hash
            } else {
                $newFilename += "_" + (Get-Date).Ticks
            }
        }
        $newFilename += $originalExtension.ToLower()

        $newPath = $originalDirectory + $newFilename

        if($DryRun -eq $false) {
            if($KeepOriginal -eq $true) {
                Copy-Item $file.Fullname $newPath
            } else {
                Move-Item $file.FullName $newPath
            }
        }

        $originalFilename + $originalExtension + " : " + $newFilename
    }
}