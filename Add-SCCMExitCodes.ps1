Import-Module (Join-Path $(Split-Path $env:SMS_ADMIN_UI_PATH) ConfigurationManager.psd1)
Set-Location "$((Get-PSDrive -PSProvider CMSite).name):"
$ApplicationName = "Enter Application Name Here"

#region exit codes
$ExitCodes = @()
$obj1 = New-Object psobject
$obj1 | Add-Member -MemberType NoteProperty -Name "Code" -Value 1
$obj1 | Add-Member -MemberType NoteProperty -Name "Class" -Value "Failure"
$obj1 | Add-Member -MemberType NoteProperty -Name "Name" -Value "Package Step Failure"
$obj1 | Add-Member -MemberType NoteProperty -Name "Description" -Value "One of the steps in the package failed"
$ExitCodes += $obj1
$obj2 = New-Object psobject
$obj2 | Add-Member -MemberType NoteProperty -Name "Code" -Value 2
$obj2 | Add-Member -MemberType NoteProperty -Name "Class" -Value "Failure"
$obj2 | Add-Member -MemberType NoteProperty -Name "Name" -Value "Unknown Step Result"
$obj2 | Add-Member -MemberType NoteProperty -Name "Description" -Value "One of the steps did not indicate success or failure. Step script should be reviewed."
$ExitCodes += $obj2
$obj3 = New-Object psobject
$obj3 | Add-Member -MemberType NoteProperty -Name "Code" -Value 3
$obj3 | Add-Member -MemberType NoteProperty -Name "Class" -Value "Failure"
$obj3 | Add-Member -MemberType NoteProperty -Name "Name" -Value "Deployment Framework Failure"
$obj3 | Add-Member -MemberType NoteProperty -Name "Description" -Value "The deployment framework was unable to execute properly."
$ExitCodes += $obj3
#endregion
Function New-ExitCodeEntry() {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [int]$Code, 

        [Parameter(Mandatory = $true)]
        [string]$Class,
        
        [Parameter(Mandatory = $true)]
        [string]$Name,  

        [Parameter(Mandatory = $true)]
        [string]$Description
    )

    $ExitCode = New-Object -TypeName Microsoft.ConfigurationManagement.ApplicationManagement.ExitCode
    $ExitCode.Code = $Code
    $ExitCode.Class = [Microsoft.ConfigurationManagement.ApplicationManagement.ExitCodeClass]"$Class"
    $ExitCode.Name = "$Name"
    $ExitCode.Description = $Description
    return $ExitCode
}

Function Set-ExitCodes() {
    $deserializedApp = [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($NewApplication.SDMPackageXML)
    foreach ($EC in $ExitCodes) {
        $deserializedApp.DeploymentTypes.Installer.ExitCodes.add((New-ExitCodeEntry -Code $EC.Code -Class $EC.Class -Name $EC.Name -Description $EC.Description))
    }
    $newAppXml = [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::Serialize($deserializedApp, $false)
    $NewApplication.SDMPackageXML = $newAppXml
    $NewApplication.Put()
}

$NewApplication = Get-CMApplication -Name $ApplicationName
Set-ExitCodes
