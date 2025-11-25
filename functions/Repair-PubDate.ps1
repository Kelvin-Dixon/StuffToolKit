function Repair-PubDate {
    param(
        [Parameter(Mandatory)]
        [string]$inputString,
        [datetime]$DateOverride
    )

    $jsonPath = "C:\Work\StuffToolKit\tests\Test-Repair-Pubdate.json"
    $pubSchedules = Get-Content $jsonPath | ConvertFrom-Json

    $dayMap = @{
        "Mon" = [DayOfWeek]::Monday
        "Tue" = [DayOfWeek]::Tuesday
        "Wed" = [DayOfWeek]::Wednesday
        "Thu" = [DayOfWeek]::Thursday
        "Fri" = [DayOfWeek]::Friday
        "Sat" = [DayOfWeek]::Saturday
        "Sun" = [DayOfWeek]::Sunday
    }

    if ($inputString -match '^([A-Z]+)-.*?(\d{8})') {
        $pubCode = $matches[1]
        $dateStr = $matches[2]
        $fileDate = [datetime]::ParseExact($dateStr, "yyyyMMdd", $null)
        $today = ($DateOverride ?? (Get-Date)).Date
        $tomorrow = $today.AddDays(1)

        # Case 1: Today
        if ($fileDate.Date -eq $today) {
            if ($pubSchedules.PSObject.Properties.Name -contains $pubCode) {
                $validDays = $pubSchedules.$pubCode | ForEach-Object { $dayMap[$_] }
                if ($validDays -contains $today.DayOfWeek) {
                    return $inputString
                }
            }
            $anchorDate = $today
        }

        # Case 2: Tomorrow
        elseif ($fileDate.Date -eq $tomorrow) {
            if ($pubSchedules.PSObject.Properties.Name -contains $pubCode) {
                $validDays = $pubSchedules.$pubCode | ForEach-Object { $dayMap[$_] }
                if ($validDays -contains $tomorrow.DayOfWeek) {
                    return $inputString
                }
            }
            $anchorDate = $tomorrow
        }

        # Case 3: Older than today
        elseif ($fileDate.Date -lt $today) {
            $anchorDate = $today
        }

        # Case 4: Future beyond tomorrow
        else {
            if ($pubSchedules.PSObject.Properties.Name -contains $pubCode) {
                $validDays = $pubSchedules.$pubCode | ForEach-Object { $dayMap[$_] }
                if ($validDays -contains $fileDate.DayOfWeek) {
                    return $inputString
                }
            }
            $anchorDate = $fileDate
        }

        # Roll forward from anchorDate
        if ($pubSchedules.PSObject.Properties.Name -contains $pubCode) {
            $validDays = $pubSchedules.$pubCode | ForEach-Object { $dayMap[$_] }
            while ($validDays -notcontains $anchorDate.DayOfWeek) {
                $anchorDate = $anchorDate.AddDays(1)
            }
            $correctedDate = $anchorDate
        }
        else {
            # Unknown pub: next same weekday after anchorDate
            $targetDay = $fileDate.DayOfWeek
            while ($anchorDate.DayOfWeek -ne $targetDay) {
                $anchorDate = $anchorDate.AddDays(1)
            }
            $correctedDate = $anchorDate
        }

        $newDateStr = $correctedDate.ToString("yyyyMMdd")
        return ($inputString -replace $dateStr, $newDateStr)
    }
    else {
        return $inputString
    }
}