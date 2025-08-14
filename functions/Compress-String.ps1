# Compresses a string by trimming leading/trailing whitespace and specified trailing characters.
function Compress-String {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [string]$inputString
    )
    process {
        # Return empty string if input is null, empty, or whitespace
        if ([string]::IsNullOrWhiteSpace($inputString)) { return "" }

        # Trim the string
        $outputString = $inputString.Trim()

         # Replace any sequence of one or more whitespace characters with a single space
        $outputString = $outputString -replace ' +', ' '

        # Only apply regex if necessary and string is not empty after trim
        # Removes trailing spaces, hyphens, dots, or commas
        if ($outputString -and $outputString -match '[ \-\.,]+$') {
            $outputString = $outputString -replace '([ \-\.,]+)$', ''
        }
        
        return $outputString
    }
}