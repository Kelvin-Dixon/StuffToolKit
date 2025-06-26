# Formats names into proper case, correctly handling "Mac", "Mc", hyphenated surnames, and multiple-word names.
function Format-Name {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [string]$name
    )

    process {
        # Trim input using Compress-String and return empty string for null, empty, or variations of "null"
        $processedName = Compress-String -inputString $name 
        if (-not $processedName -or $processedName -match '^(?i)null$') { return "" }

        # Remove leading "-" followed by any spaces
        $processedName = $processedName -replace '^-+\s*', ''
        if (-not $processedName) { return "" } # Return if string becomes empty

        # Handle specific cases like "CAMP TR", "Camp Tr", "Camp tr" and return "Campaign Track"
        if ($processedName -match '^(?i)camp\s*tr\s*$') { 
            return "Campaign Track"
        }

        # Handle specific cases like "No Chase", "no chase", "No CHASE" and return ""
        if ($processedName -match '(?i)\bno\s+c') { 
            return ""
        }

        # Handle tba cases (ensure it's not part of a longer word)
        if ($processedName -match '(?i)\btba\b') { 
            return ""
        }

        if ($processedName -match '(?i)do not use') { 
            return ""
        }

        # Check if the string contains 'left', 'no longer', or 'leaving'
        if ($processedName -match '(?i)\b(left|no\s+longer|leaving)\b') { 
            return ""
        }

        # Known exceptions that should NOT follow the Mac/Mc capitalization rules
        $exceptions = @("Macintosh", "Mackenzie", "Mackay", "Macleod", "Macon", "Maconochie", "McCoy")

        # Convert to lowercase and split by spaces. Filter out empty strings from split.
        $nameParts = ($processedName.ToLower() -split '\s+' | Where-Object {$_})

        $formattedNameParts = $nameParts | ForEach-Object {
            $currentPart = $_
            $formattedCurrentPart = ""

            # Preserve known exceptions
            $exceptionMatch = $exceptions | Where-Object { $_ -eq $currentPart } 
            if ($exceptionMatch) { 
                if ($exceptionMatch.Length -gt 1) {
                    $formattedCurrentPart = $exceptionMatch.Substring(0, 1).ToUpper() + $exceptionMatch.Substring(1)
                } elseif ($exceptionMatch.Length -eq 1) {
                    $formattedCurrentPart = $exceptionMatch.ToUpper()
                } else {
                    $formattedCurrentPart = "" 
                }
            }
            # Handle Mac/Mc cases properly
            elseif ($currentPart -match '^mac[a-z]' -and $currentPart -ne "macintosh") { 
                if ($currentPart.Length -gt 3) { 
                    $formattedCurrentPart = 'Mac' + ($currentPart.Substring(3,1).ToUpper() + $currentPart.Substring(4))
                } elseif ($currentPart.Length -eq 3) { 
                    $formattedCurrentPart = 'Mac'
                } else { 
                    $formattedCurrentPart = $currentPart.ToUpper()
                }
            }
            elseif ($currentPart -match '^mc[a-z]') {
                if ($currentPart.Length -gt 2) { 
                    $formattedCurrentPart = 'Mc' + ($currentPart.Substring(2,1).ToUpper() + $currentPart.Substring(3))
                } elseif ($currentPart.Length -eq 2) { 
                    $formattedCurrentPart = 'Mc'
                } else { 
                    $formattedCurrentPart = $currentPart.ToUpper()
                }
            }
            # Handle hyphenated names recursively
            elseif ($currentPart -match "-") {
                # Split by hyphen, recursively format each part, then rejoin
                $hyphenSubParts = $currentPart -split "-"
                $reformattedHyphenSubParts = $hyphenSubParts | ForEach-Object {
                    Format-Name -name $_ # Recursive call
                }
                $formattedCurrentPart = $reformattedHyphenSubParts -join "-" # Rejoin with hyphen
            }
            # Handle apostrophe names (if not hyphenated)
            elseif ($currentPart -match "'") {
                # Split by apostrophe, capitalize each part, then rejoin
                $apostropheSubParts = $currentPart -split "'"
                $reformattedApostropheSubParts = $apostropheSubParts | ForEach-Object {
                    if ($_.Length -gt 1) {
                        $_.Substring(0,1).ToUpper() + $_.Substring(1)
                    } elseif ($_.Length -eq 1) {
                        $_.ToUpper()
                    } else {
                        "" 
                    }
                }
                $formattedCurrentPart = $reformattedApostropheSubParts -join "'" # Rejoin with apostrophe
            }
            # General case: Capitalize first letter
            else {
                if ($currentPart.Length -gt 1) {
                    $formattedCurrentPart = $currentPart.Substring(0,1).ToUpper() + $currentPart.Substring(1)
                } elseif ($currentPart.Length -eq 1) {
                    $formattedCurrentPart = $currentPart.ToUpper()
                } else {
                    $formattedCurrentPart = "" 
                }
            }
            $formattedCurrentPart # Output the processed part for this iteration
        }
        return $formattedNameParts -join ' '
    }
}