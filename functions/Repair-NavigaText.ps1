# Compresses a string by trimming leading/trailing whitespace and specified trailing characters.
function Repair-NavigaText {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$inputString
    )
    process {
        if (-not $inputString) { return "" } # Handle null or empty input early
        
        $patched = $InputString `
            -replace '(&#x[0-9A-Fa-f]+)(?!;)', '$1;' `
            -replace '(&#[0-9]+)(?!;)', '$1;'
        $patched = Convert-Diacritics -inputString $patched
        $outputBuilder = New-Object System.Text.StringBuilder

        foreach ($char in $patched.ToCharArray()) {
            $codePoint = [int][char]$char

            # Preserve newlines (if the character is a newline, we append it directly)
            if ($char -eq "`n" -or $char -eq "`r") {
                [void]$outputBuilder.Append($char)
            }
            # Keep valid ranges for diacritics
            elseif (($codePoint -ge 0x0021 -and $codePoint -le 0x007E) -or # Basic Latin (printable)
                ($codePoint -ge 0x00A1 -and $codePoint -le 0x00FF) -or # Latin-1 Supplement
                ($codePoint -ge 0x0100 -and $codePoint -le 0x017E)) {
                # Latin Extended-A (some common diacritics)
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
        $finalString = Compress-String -inputString $outputBuilder.ToString() 

        foreach ($pair in $macronMap.GetEnumerator()) {
            $finalString = $finalString -replace [regex]::Escape($pair.Key), $pair.Value
        }

        #remove any unwanted characters:
        $finalString = $finalString -replace '\|', '-' #replace pipes with dashes

        return $finalString
    }
}
