# Renamed the function to Set-Env
function Set-Env {
    [CmdletBinding()]
    param (
        [switch]$IsProd
    )

    # The logic inside remains the same
    $script:isProdEnvironment = $IsProd.IsPresent
}