#-----------------------------------------------------------------------
# SCRIPT CONFIGURATION
$isProd = $false # Set to $true for production environment
$logFile = "$PWD\logs\Test-StuffToolkit.log"
#-----------------------------------------------------------------------
# --- Setup ---
Import-Module "$PWD\StuffToolkit.psd1" -Force -DisableNameChecking

# Configure the Module Environment
Set-NavigaEnv -IsProd:$isProd
Set-LogFile -Path $logFile

# (The Invoke-TestCases function from above should be placed here)

# --- Main Application ---
$OverallPassCount = 0
$OverallFailCount = 0
Clear-Host

# --- Test Case Definitions (Your complete, original data) ---

$repairHtmlEntitiesTestCases = @(
    @{ Input = "Hello &#x201C;World&#8221; &#169; 2024 &#x2665;"; Expected = 'Hello “World” © 2024 ♥' },
    @{ Input = "Julie O&#8217 Brien"; Expected = "Julie O’ Brien" },
    @{ Input = "779 COLOMBO ST T/A The Victoria Pub & Dining Rooms"; Expected = "779 COLOMBO ST T/A The Victoria Pub & Dining Rooms" }
)

$plainTestCases = @(
    @{ Input = "Héllö—Wörld" ; Expected = "Hello-World" },
    @{ Input = @"
Don't do "this" anymore
"@ ; Expected = "Don't do ""this"" anymore" },
    @{ Input = "   This has    extra spaces and diacritics!   " ; Expected = "This has extra spaces and diacritics!" },
    @{ Input = "Fiancé" ; Expected = "Fiance" },
    @{ Input = "Abdul ." ; Expected = "Abdul" },
    @{ Input = "Crème brûlée" ; Expected = "Creme brulee" },
    @{ Input = "Test String." ; Expected = "Test String" },
    @{ Input = "Test String-" ; Expected = "Test String" },
    @{ Input = "Test String, " ; Expected = "Test String" },
    @{ Input = "Test String - " ; Expected = "Test String" },
    @{ Input = "&#8217;s test" ; Expected = "'s test" },
    @{ Input = " " ; Expected = "" },
    @{ Input = $null ; Expected = "" }
)

$diacriticsTestCases = @(
    @{ Input = "Héllö—Wörld" ; Expected = "Héllö-Wörld" },
    @{ Input = @"
Don't do "this" anymore
"@ ; Expected = "Don't do ""this"" anymore" },
    @{ Input = "Newline`nTest`r`nPreservation" ; Expected = "Newline`nTest`r`nPreservation" },
    @{ Input = "Non-standard character: 😂" ; Expected = "Non-standard character:" }, # Emoji replaced with space
    @{ Input = "Fiancé" ; Expected = "Fiancé" },
    @{ Input = "Crème brûlée" ; Expected = "Crème brûlée" },
    @{ Input = "Test String. " ; Expected = "Test String" },
    @{ Input = "&#x2019;s test" ; Expected = "'s test" },
    @{ Input = $null ; Expected = "" }
)

$compressTestCases = @(
    @{ Input = "   Hello World   " ; Expected = "Hello World" },
    @{ Input = "Hello World." ; Expected = "Hello World" },
    @{ Input = "Hello World-" ; Expected = "Hello World" },
    @{ Input = "Hello World, " ; Expected = "Hello World" },
    @{ Input = "Hello World - " ; Expected = "Hello World" },
    @{ Input = "   Leading and trailing spaces, dots... " ; Expected = "Leading and trailing spaces, dots" },
    @{ Input = "   " ; Expected = "" },
    @{ Input = "" ; Expected = "" },
    @{ Input = $null ; Expected = "" }
)

$nameTestCases = @(
    @{ Input = "john doe" ; Expected = "John Doe" },
    @{ Input = "MARY JANE" ; Expected = "Mary Jane" },
    @{ Input = "mcarthur" ; Expected = "McArthur" },
    @{ Input = "macdonald" ; Expected = "MacDonald" },
    @{ Input = "macintosh" ; Expected = "Macintosh" },
    @{ Input = "Mackenzie" ; Expected = "Mackenzie" },
    @{ Input = "o'connor" ; Expected = "O'Connor" },
    @{ Input = "van der merwe" ; Expected = "Van Der Merwe" },
    @{ Input = "smith-jones" ; Expected = "Smith-Jones" },
    @{ Input = "   - leading hyphen " ; Expected = "Leading Hyphen" },
    @{ Input = "   camp tr   " ; Expected = "Campaign Track" },
    @{ Input = "NO CHASE" ; Expected = "" },
    @{ Input = "tba" ; Expected = "" },
    @{ Input = "Do Not Use" ; Expected = "" },
    @{ Input = "employee left" ; Expected = "" },
    @{ Input = "status no longer active" ; Expected = "" },
    @{ Input = "Leaving soon" ; Expected = "" },
    @{ Input = "null" ; Expected = "" },
    @{ Input = "" ; Expected = "" },
    @{ Input = $null ; Expected = "" },
    @{ Input = "single" ; Expected = "Single" }
)

$navigaTestCases =@(
    @{ Input = "ÅŒtautahi" ; Expected = "Ōtautahi" },
    @{ Input = "Julie O&#8217 Brien" ; Expected = "Julie O' Brien" },
    @{ Input = "Te R&#x101kau Hua o Te Wao Tapu" ; Expected = "Te Rākau Hua o Te Wao Tapu" },
    @{ Input = "Petone Memorial Park &#x100 &#x112 &#x12A &#332 &#362 &#x101 &#x113 &#x12B &#333 &#363" ; Expected = "Petone Memorial Park Ā Ē Ī Ō Ū ā ē ī ō ū" }
    @{ Input = "I Hate | Pipes" ; Expected = "I Hate - Pipes" }
)

$pubDateTestCases = @(
    # --- WWK (Mon, Wed, Fri) ---
    @{ Input = "WWK-ED1-ZN-20251119" ; Expected = "WWK-ED1-ZN-20251124" }, # Older Wed → Mon
    @{ Input = "WWK-ED1-ZN-20251121" ; Expected = "WWK-ED1-ZN-20251124" }, # Older Fri → Mon
    @{ Input = "WWK-ED1-ZN-20251124" ; Expected = "WWK-ED1-ZN-20251124" }, # Today Mon → unchanged
    @{ Input = "WWK-ED1-ZN-20251125" ; Expected = "WWK-ED1-ZN-20251126" }, # Tomorrow Tue → roll forward to Wed

    # --- XYZ (Tue, Thu) ---
    @{ Input = "XYZ-ED1-ZN-20251120" ; Expected = "XYZ-ED1-ZN-20251125" }, # Older Thu → Tue
    @{ Input = "XYZ-ED1-ZN-20251124" ; Expected = "XYZ-ED1-ZN-20251125" }, # Today Mon → Tue
    @{ Input = "XYZ-ED1-ZN-20251125" ; Expected = "XYZ-ED1-ZN-20251125" }, # Tomorrow Tue  → unchanged
    @{ Input = "XYZ-ED1-ZN-20251126" ; Expected = "XYZ-ED1-ZN-20251127" }, # Wed  → Thu
    @{ Input = "XYZ-ED1-ZN-20251127" ; Expected = "XYZ-ED1-ZN-20251127" }, # Thu  → unchanged

    # --- ABC (Sun only) ---
    @{ Input = "ABC-ED1-ZN-20251116" ; Expected = "ABC-ED1-ZN-20251130" }, # Older Sun → next Sun (30 Nov)
    @{ Input = "ABC-ED1-ZN-20251123" ; Expected = "ABC-ED1-ZN-20251130" }, # Yesterday Sun → next Sun (30 Nov)
    @{ Input = "ABC-ED1-ZN-20251124" ; Expected = "ABC-ED1-ZN-20251130" }, # Today Mon → roll forward to Sun (30 Nov)
    @{ Input = "ABC-ED1-ZN-20251125" ; Expected = "ABC-ED1-ZN-20251130" }, # Tomorrow Tue → roll forward to Sun (30 Nov)
    @{ Input = "ABC-ED1-ZN-20251130" ; Expected = "ABC-ED1-ZN-20251130" }, # Next Sun → unchanged

    # --- Unknown pub ---
    @{ Input = "ZZZ-ED1-ZN-20251119" ; Expected = "ZZZ-ED1-ZN-20251126" }, # Older Wed → next Wed
    @{ Input = "ZZZ-ED1-ZN-20251120" ; Expected = "ZZZ-ED1-ZN-20251127" }, # Older Thu → next Thu
    @{ Input = "ZZZ-ED1-ZN-20251124" ; Expected = "ZZZ-ED1-ZN-20251124" }, # Today Mon → unchanged
    @{ Input = "ZZZ-ED1-ZN-20251125" ; Expected = "ZZZ-ED1-ZN-20251125" }, # Tomorrow Tue → unchanged

    # --- Invalid pattern ---
    @{ Input = "RandomFile.pdf" ; Expected = "RandomFile.pdf" } # unchanged
)

# --- Execute All Tests Using the Helper Function ---

$results = Invoke-TestCases -TestName "Repair-HtmlEntities" -FunctionName "Repair-HtmlEntities" -TestCases $repairHtmlEntitiesTestCases -Show $false
$OverallPassCount += $results.PassCount
$OverallFailCount += $results.FailCount

$results = Invoke-TestCases -TestName "Convert-Plain" -FunctionName "Convert-Plain" -TestCases $plainTestCases -Show $false
$OverallPassCount += $results.PassCount
$OverallFailCount += $results.FailCount

$results = Invoke-TestCases -TestName "Convert-Diacritics" -FunctionName "Convert-Diacritics" -TestCases $diacriticsTestCases -Show $false
$OverallPassCount += $results.PassCount
$OverallFailCount += $results.FailCount

$results = Invoke-TestCases -TestName "Compress-String" -FunctionName "Compress-String" -TestCases $compressTestCases -Show $false
$OverallPassCount += $results.PassCount
$OverallFailCount += $results.FailCount

$results = Invoke-TestCases -TestName "Format-Name" -FunctionName "Format-Name" -TestCases $nameTestCases -Show $false
$OverallPassCount += $results.PassCount
$OverallFailCount += $results.FailCount

$results = Invoke-TestCases -TestName "Repair-NavigaText" -FunctionName "Repair-NavigaText" -TestCases $navigaTestCases -Show $false
$OverallPassCount += $results.PassCount
$OverallFailCount += $results.FailCount

$results = Invoke-TestCases -TestName "Repair-PubDate" -FunctionName "Repair-PubDate" -TestCases $pubDateTestCases -Show $false
$OverallPassCount += $results.PassCount
$OverallFailCount += $results.FailCount

$config = Get-NavigaConfig
if ($config) {
    Write-Host "Naviga Config Loaded Successfully:" -ForegroundColor Green
    Write-Host "ClientId: $($config.ClientId)"
    Write-Host "RootURI: $($config.RootURI)"
} else {
    Write-Host "Failed to load Naviga Config." -ForegroundColor Red
}

# --- Final Summary ---
Write-Host "--- All Tests Completed ---" -ForegroundColor Cyan
Write-Host ""
$OverallTotalTests = $OverallPassCount + $OverallFailCount
if ($OverallFailCount -eq 0) {
    Write-Host "Overall Test Summary: ALL $($OverallPassCount) TESTS PASSED!" -ForegroundColor Green
} else {
    Write-Host "Overall Test Summary: $($OverallPassCount) PASS, $($OverallFailCount) FAIL out of $($OverallTotalTests) Tests." -ForegroundColor Red
}