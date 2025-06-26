# functions/Write-Log.ps1
function Write-Log {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message
    )

    try {
        if (-not ($script:LogFilePath)) {
            Write-Error "Log file path has not been set. Please run Set-LogFile first."
            return
        }
        #Combine the preferred timestamp format with the -f operator for a clean, single line.
        $logMessage = "{0} - {1}" -f (Get-Date).ToString("HH:mm:ss"), $Message
        
        # Ensure the directory exists for the log file
        $logDirectory = Split-Path -Path $script:LogFilePath
        if ($logDirectory -and (-not (Test-Path -Path $logDirectory -PathType Container))) {
            New-Item -Path $logDirectory -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
        }

        # Write the log message to the file with explicit UTF-8 encoding.
        Add-Content -Path $script:LogFilePath -Value $logMessage -Encoding utf8

    }
    catch {
        <#Do this if a terminating exception happens#>
        Write-Error "Failed to write to log file '$script:LogFilePath': $($_.Exception.Message)"
    }
}