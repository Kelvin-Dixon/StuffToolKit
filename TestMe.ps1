Import-Module "$PWD\StuffToolkit.psd1" -Force
Get-Stuff
Set-LogFile -Path "$PWD\Logs\StuffToolKit.log"
Write-Log -Message "This is a test log message."    