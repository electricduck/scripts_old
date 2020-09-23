param (
    [string]$OutFolder
)

$downloaded = 0
$nextBatch = 0
$total = 1

function Download-FileList {
    param (
        [Parameter(Mandatory=$true)][string]$Index
    )

    $eventId = "1c547f94-7956-4e09-970e-ed3cfb414bd4"

    $resource = "https://uktickets.gearblast.com/gallery/search?ev=" + $eventId + "&q=&s=" + $Index

    $apiResult = Invoke-RestMethod -Method Get -Uri $resource

    $total = $apiResult.totalPhotoCount

    Download-Files $apiResult.photos
}

function Download-Files {
    param (
        [Object]$FileList
    )

    $nextBatch = $downloaded + $apiResult.photos.Length

    foreach($photo in $FileList) {
        Download-Photo $photo.id
        $downloaded++
    }

    Download-FileList $nextBatch
}

function Download-Photo {
    param (
        [string]$Id
    )

    $resource = "https://uktickets.gearblast.com/gallery/download/" + $Id

    $filename = "photo_GearblastUK2019." + "{0:0000}" -f $downloaded + "-" + (Get-Date).Ticks + ".jpg"
    $filename

    Invoke-WebRequest -Uri $resource -outfile $filename

    move-item $filename $OutFolder
}

Download-FileList $nextBatch
