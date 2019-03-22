param(
    [Parameter(Mandatory=$true)][string]$Path
)

$PathWithoutGifExtension = $Path.Replace(".gif","")
$PathWithMp4Extension = $PathWithoutGifExtension + ".mp4"

ffmpeg -i $Path -movflags faststart -pix_fmt yuv420p -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" $PathWithMp4Extension