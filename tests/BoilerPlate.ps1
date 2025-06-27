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