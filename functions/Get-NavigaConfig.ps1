function Get-NavigaConfig {
    [CmdletBinding()]
    param ()

    $environmentName = "Test" # Default to Test

    # Check the variable that lives INSIDE our own module scope.
    # This is 100% reliable.
    if ($script:isProdEnvironment -eq $true) {
        $environmentName = "Prod"
    }
    
    # ... The rest of the function remains the same ...
    
    if (-not $script:NavigaConfigPath) {
        throw "Naviga config file path has not been defined within the module."
    }
    if (-not (Test-Path -Path $script:NavigaConfigPath)) {
        throw "Configuration file not found at the hardcoded path: '$($script:NavigaConfigPath)'"
    }

    [xml]$myConfig = Get-Content -Path $script:NavigaConfigPath

    return @{
        ClientId     = $myConfig.config.NavigaAuth.$environmentName.ClientId
        ClientSecret = $myConfig.config.NavigaAuth.$environmentName.ClientSecret
        RootURI      = $myConfig.config.NavigaAuth.$environmentName.RootURI
    }
}