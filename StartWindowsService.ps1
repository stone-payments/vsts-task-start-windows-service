[CmdletBinding()]
param([switch]$dotSourceOnly)
function Main () {
    # For more information on the VSTS Task SDK:
    # https://github.com/Microsoft/vsts-task-lib
    Trace-VstsEnteringInvocation $MyInvocation
    try {
        
        $serviceName = Get-VstsInput -Name "ServiceName" -Require
        Start-Service $serviceName
        try{
            $service = Get-Service $serviceName
            if($service.status -eq "Running"){
                Write-Host "Service $service.name started successfully."
            }
        }catch{
            throw "Service $service could not be started."
        }
                     
    } finally {
        Trace-VstsLeavingInvocation $MyInvocation
    }
}

if($dotSourceOnly -eq $false){
    Main
}
