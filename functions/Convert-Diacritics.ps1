# Replaces or removes diacritic characters based on a mapping, preserving valid ASCII and Latin-1 ranges while maintaining newlines.
function Convert-Diacritics {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [string]$inputString
    )

    process {
        if (-not $inputString) { return "" } # Handle null or empty input early
        $decodedInputString = Convert-NumericHtmlEntity -inputString $inputString

        $outputBuilder = New-Object System.Text.StringBuilder

        foreach ($char in $decodedInputString.ToCharArray()) {
            $codePoint = [int][char]$char

            # Preserve newlines (if the character is a newline, we append it directly)
            if ($char -eq "`n" -or $char -eq "`r") {
                [void]$outputBuilder.Append($char)
            }
            # Keep valid ranges for diacritics
            elseif (($codePoint -ge 0x0021 -and $codePoint -le 0x007E) -or # Basic Latin (printable)
                    ($codePoint -ge 0x00A1 -and $codePoint -le 0x00FF) -or # Latin-1 Supplement
                    ($codePoint -ge 0x0100 -and $codePoint -le 0x017E)) { # Latin Extended-A (some common diacritics)
                [void]$outputBuilder.Append($char)
            }
            # Replace mapped characters
            elseif ($script:replacementMap.ContainsKey($char)) {
                [void]$outputBuilder.Append($script:replacementMap[$char])
            }
            # Remove all other characters (replace with space to avoid collapsing words unintentionally)
            else {
                [void]$outputBuilder.Append(" ")
            }
        }

        # Return trimmed and formatted string
        return Compress-String -inputString $outputBuilder.ToString() 
    }
}