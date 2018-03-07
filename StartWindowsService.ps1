[CmdletBinding()]
param([switch]$dotSourceOnly)
function Main () {
    # For more information on the VSTS Task SDK:
    # https://github.com/Microsoft/vsts-task-lib
    Trace-VstsEnteringInvocation $MyInvocation
    try {
        
        $serviceName = Get-VstsInput -Name "ServiceName" -Require

        # Find the service or abort
        $service = Get-Service $serviceName -ErrorAction Continue            
        if (-not $service){
            throw "Service could not be found on the machine."
        }
        
        #sc.exe has better error messages than powershell.
        $serviceControllerReturn = Invoke-Expression -Command "sc.exe start $($service.name)"
        if($LASTEXITCODE -eq 0){
            Write-Host "Service $serviceName started successfully."
        }else{
            throw "Failed to start $serviceName. Error: `n $serviceControllerReturn"
        }
        
    } finally {
        Trace-VstsLeavingInvocation $MyInvocation
    }
}

if($dotSourceOnly -eq $false){
    Main
}
