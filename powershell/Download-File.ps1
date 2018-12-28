param(
    [Parameter(Mandatory=$true)][string]$Uri,
    [bool]$IncludeDomain = $true,
    [string]$OutFolder,
    [bool]$BypassAdjustments = $false
)

function Adjust-InputUri {
    param(
        [string]$InUri
    )

    if(!$InUri.StartsWith("http")) {
        $InUri = "http://" + $InUri
    }

    if($BypassAdjustments -eq $false) {

        if($InUri -like "http*media.tumblr.com/*") {
            $uriSegments = $InUri.Split("/")

            $InUri = $InUri.Replace($uriSegments[2], "media.tumblr.com")

            $InUri = $InUri.Replace("_400.jpg", "_1280.jpg")
            $InUri = $InUri.Replace("_400.png", "_1280.png")
            $InUri = $InUri.Replace("_400.gif", "_1280.gif")

            $InUri = $InUri.Replace("_500.jpg", "_1280.jpg")
            $InUri = $InUri.Replace("_500.png", "_1280.png")
            $InUri = $InUri.Replace("_500.gif", "_1280.gif")

            $InUri = $InUri.Replace("_540.jpg", "_1280.jpg")
            $InUri = $InUri.Replace("_540.png", "_1280.png")
            $InUri = $InUri.Replace("_540.gif", "_1280.gif")
        }
        
    }

    $OutUri = $InUri
    $OutUri
}

$Uri = Adjust-InputUri -InUri $Uri

$uriSegments = $Uri.Split("/")

$domain = $uriSegments[2]
$filename = $uriSegments[-1]

if($IncludeDomain) {
    $newFilename = $domain + "~" + $filename
} else {
    $newFilename = $filename
}

$newFilename

if($OutFolder) {
    if(!$OutFolder.EndsWith("/")) {
        $OutFolder += "/"
    }

    $newFilename = $OutFolder + $newFilename
}

Invoke-WebRequest -Uri $Uri -OutFile $newFilename
