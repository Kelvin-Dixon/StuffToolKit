#-----------------------------------------------------------------------
# SCRIPT CONFIGURATION
$isProd = $false # Set to $true for production environment
$logFile = "$PWD\logs\MyMainProcess.log"
#-----------------------------------------------------------------------

# --- Setup ---
Import-Module "$PWD\StuffToolkit.psd1" -Force

# This script needs both, so it configures both.
Set-Env -IsProd:$isProd
Set-LogFile -Path $logFile

# --- Main Application ---
Write-Log -Message "Starting main process..."
$appConfig = Get-NavigaConfig
# ... use $appConfig ...
Write-Host "ClientID: $($appConfig.ClientId)"
Write-Host "RootURI:  $($appConfig.RootURI)"
Write-Log "ClientID: $($appConfig.ClientId)"
Write-Log "RootURI:  $($appConfig.RootURI)"

Write-Log -Message "Main process finished."