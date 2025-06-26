function Convert-NumericHtmlEntity {
    param (
        [string]$HtmlEncodedString
    )
    $pattern = '&#(\d+);?'
    $regexDecodedString = [regex]::Replace($HtmlEncodedString, $pattern, {
        param($match)
        return [char][int]$match.Groups[1].Value
    })
    $finalDecodedString = [System.Net.WebUtility]::HtmlDecode($regexDecodedString)
    return $finalDecodedString
}