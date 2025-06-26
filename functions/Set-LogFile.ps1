# functions/Set-LogFile.ps1
function Set-LogFile {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )

    # Store the path in a variable scoped to the entire module (the script scope of the module)
    $script:LogFilePath = $Path
}