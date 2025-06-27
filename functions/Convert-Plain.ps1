# Normalizes a string by removing diacritic marks, applying character replacements, and trimming the result for clean output.
function Convert-Plain {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [string]$inputString
    )

    process {
        # Fast exit for empty strings
        if (-not $inputString) { return "" }
        $decodedInputString = Convert-NumericHtmlEntity -inputString $inputString

        # Use a StringBuilder for efficient string handling
        $sb = New-Object System.Text.StringBuilder $decodedInputString.Length

        # Normalize input to decomposed form (splitting diacritics)
        $normalizedString = $decodedInputString.Normalize([System.Text.NormalizationForm]::FormD)

        # Convert string to character array for fast processing
        foreach ($char in $normalizedString.ToCharArray()) {
            # Remove diacritic marks (Unicode category 'Mn' - Mark, Nonspacing)
            if ([System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($char) -eq [System.Globalization.UnicodeCategory]::NonSpacingMark) {
                continue
            }

            # Apply replacements if character is in the map
            if ($script:replacementMap.ContainsKey($char)) {
                [void]$sb.Append($script:replacementMap[$char])
            } else {
                [void]$sb.Append($char)
            }
        }

        # Convert back to string and trim the result using Compress-String function
        $outputString = $sb.ToString()
        return Compress-String -inputString $outputString 
    }
}