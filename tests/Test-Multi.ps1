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
)

# --- Execute All Tests Using the Helper Function ---

$results = Invoke-TestCases -TestName "Repair-HtmlEntities" -FunctionName "Repair-HtmlEntities" -TestCases $repairHtmlEntitiesTestCases
$OverallPassCount += $results.PassCount
$OverallFailCount += $results.FailCount

$results = Invoke-TestCases -TestName "Convert-Plain" -FunctionName "Convert-Plain" -TestCases $plainTestCases
$OverallPassCount += $results.PassCount
$OverallFailCount += $results.FailCount

$results = Invoke-TestCases -TestName "Convert-Diacritics" -FunctionName "Convert-Diacritics" -TestCases $diacriticsTestCases
$OverallPassCount += $results.PassCount
$OverallFailCount += $results.FailCount

$results = Invoke-TestCases -TestName "Compress-String" -FunctionName "Compress-String" -TestCases $compressTestCases
$OverallPassCount += $results.PassCount
$OverallFailCount += $results.FailCount

$results = Invoke-TestCases -TestName "Format-Name" -FunctionName "Format-Name" -TestCases $nameTestCases
$OverallPassCount += $results.PassCount
$OverallFailCount += $results.FailCount

$results = Invoke-TestCases -TestName "Repair-NavigaText" -FunctionName "Convert-Diacritics" -TestCases $navigaTestCases
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