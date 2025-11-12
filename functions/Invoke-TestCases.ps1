# =======================================================================
# Reusable Test Helper Function
# =======================================================================
function Invoke-TestCases {
    param (
        [Parameter(Mandatory = $true)]
        [string]$TestName,

        [Parameter(Mandatory = $true)]
        [string]$FunctionName,

        [Parameter(Mandatory = $true)]
        [array]$TestCases,

        [Parameter(Mandatory = $true)]
        [bool]$Show = $false   # Default to false
    )

    # Define the format string once. This is our template.
    $formatTemplate = "{0, -35} {1, -35} {2, -35} {3}"
    
    # Initialize local counters for this test group
    $localPassCount = 0
    $localFailCount = 0

    Write-Host "--- Testing $TestName ---" -ForegroundColor Cyan

    foreach ($case in $TestCases) {
        $original = $case.Input
        $expected = $case.Expected
        $result = & $FunctionName -inputString $original
        
        # Check if the test passed or failed to set the status and color
        if ($result -eq $expected) {
            $status = "PASS"
            $color = "Green"
            $localPassCount++
        }
        else {
            $status = "FAIL"
            $color = "Red"
            $localFailCount++
        }
        
        # Build and write the single, perfectly formatted output line
        if ($status -eq "FAIL" -or $Show) {
            $outputLine = $formatTemplate -f "Input: '$original'", "Expected: '$expected'", "Result: '$result'", "Status: '$status'"
            Write-Host $outputLine -ForegroundColor $color
        }
    }

    # Write the summary for this specific test group
    $totalTests = $localPassCount + $localFailCount
    Write-Host "$TestName Tests: $localPassCount/$totalTests PASS, $localFailCount FAIL" -ForegroundColor Cyan
    Write-Host ""

    # Return the results so we can calculate the overall summary
    return [PSCustomObject]@{
        PassCount = $localPassCount
        FailCount = $localFailCount
    }
}
# =======================================================================