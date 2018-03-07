# Find and import source script.
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$systemUnderTest = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$srcDir = "$here\.."
. "$srcDir\$systemUnderTest" -dotSourceOnly

# Import vsts sdk.
$vstsSdkPath = Join-Path $PSScriptRoot ..\ps_modules\VstsTaskSdk\VstsTaskSdk.psm1 -Resolve
Import-Module -Name $vstsSdkPath -Prefix Vsts -ArgumentList @{ NonInteractive = $true } -Force

Describe "Main" {
    # General mocks needed to control flow and avoid throwing errors.
    Mock Trace-VstsEnteringInvocation -MockWith {}
    Mock Trace-VstsLeavingInvocation -MockWith {}

    $serviceName = "MyService"
    Mock Get-VstsInput -ParameterFilter { $Name -eq "ServiceName" } -MockWith { return $serviceName } 

    Context "When tries to find the service and cannot find it" {
        Mock Get-Service {$null}
        It "Should throw an exception"{
            
            {Main} | Should -Throw "Service could not be found on the machine."
        }        
    }

    Context "When the service can be successfully started"{
        It "Should show a message alerting the user"{
            $global:LASTEXITCODE = 0
            Mock Invoke-Expression {}
            Mock Write-Host {}
            Mock Get-Service {"Service!"}
            Main
            Assert-MockCalled Write-Host -ParameterFilter {$Object -eq "Service $serviceName started successfully."}
        }
    }
    Context "When the service CANNOT be started"{
        It "Should show a message alerting the user and throw the error message"{
            $errorMessage = "This is the error message!"
            $global:LASTEXITCODE = -1
            Mock Invoke-Expression {$errorMessage}
            Mock Write-Host {}
            Mock Get-Service {"Service!"}
            {Main} | Should -Throw $errorMessage
            Assert-MockCalled Write-Host -ParameterFilter {$Object -eq "Failed to start $serviceName. Error:"}
        }
    }
}

