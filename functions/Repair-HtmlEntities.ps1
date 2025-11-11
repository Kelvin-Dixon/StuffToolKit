# Repairs missing ; after HtmlEncoded text.
function Repair-HtmlEntities {
    param (
        [string]$inputString
    )
    $pattern = '&#(\d+);?'
    $regexDecodedString = [regex]::Replace($inputString, $pattern, {
        param($match)
        return [char][int]$match.Groups[1].Value
    })
    $finalDecodedString = [System.Net.WebUtility]::HtmlDecode($regexDecodedString)
    return $finalDecodedString
}