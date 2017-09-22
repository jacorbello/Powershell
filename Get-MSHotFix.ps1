<#
.Synopsis
    Get-MSHotfix.ps1 - Gathers list of Hotfixes for requested computers
.DESCRIPTION
    Gathers list of Hotfixes for requested computers. Can be narrowed down for specific hotfixes
.EXAMPLE
    .\Get-MSHotFix.ps1 -ComputerName ITS-111111,ITS-111112 -SMBv1
.EXAMPLE
    .\Get-MSHotFix.ps1 -KB KB1234567,KB7654321 -PresentOnly
.PARAMETER ComputerName
    Comma separated list of Computer Names
.PARAMETER ImportFile
    File path for list of computers
.PARAMETER SMBv1
    SMBv1 List of KBs
.PARAMETER PresentOnly
    Only display KBs present on computers
.PARAMETER KB
    Comma separated list of KB to search for
.PARAMETER PassCredentials
    Script will request credentials to query remote machines
.PARAMETER ImportKBs
    File path for list of KBs
.NOTES
    Written by Jeremy Corbello
    V1.0 - 8/30/2017 - Initial Version

    *Website - www.JeremyCorbello.com
#>

[CmdletBinding()]
param (  
        [Parameter( Mandatory=$false)]
        [string[]]$ComputerName,
        
        [Parameter( Mandatory=$false)]
        [string]$ImportComputers,

        [Parameter( Mandatory=$false)]
        [switch]$SMBv1,

        [Parameter( Mandatory=$false)]
        [switch]$PresentOnly,

        [Parameter( Mandatory=$false)]
        [string[]]$KB,
        
        [Parameter( Mandatory=$false)]
        [string]$ImportKBs,

        [Parameter( Mandatory=$false)]
        [switch]$PassCredentials
    )


if (!($ComputerName) -AND !($ImportComputers)) {
    $ComputerName = $env:COMPUTERNAME
    } elseif ($ImportComputers) {
    [string[]]$ComputerName = Get-Content -Path $ImportComputers
    }
$PatchList = @()
$SMBv1List = "KB4012598","KB4012212","KB4012215","KB4012213","KB4012216","KB4012214","KB4012217","KB4012606","KB4013198","KB4013429"

if ($SMBv1) {
    $PatchList += $SMBv1List
    }

if ($kb) {
    foreach ($j in $kb) {
        $PatchList += $j
        }
    }
if ($ImportKBs) {
    $PatchList += Get-Content -Path $ImportKBs
    }

if ($PassCredentials) {
    $creds = (Get-Credential)
    }


Function Get-UpdateList {
    [CmdletBinding()]
    param (
        [Parameter( Mandatory=$true)]
        [string]$ComputerName,

        [Parameter( Mandatory=$false)]
        [string]$Patch
        )
    if ($Patch) {
        if ($PassCredentials) {
            return (Get-Hotfix -ComputerName $ComputerName -Credential $creds -Id $Patch -ErrorAction SilentlyContinue).hotfixid
        } else {
            return (Get-Hotfix -ComputerName $ComputerName -Id $Patch -ErrorAction SilentlyContinue).hotfixid
        }
    } else {
        if ($PassCredentials) {
            return (Get-HotFix -ComputerName $ComputerName -Credential $creds -ErrorAction SilentlyContinue).hotfixid
        } else {
            return (Get-Hotfix -ComputerName $ComputerName -ErrorAction SilentlyContinue).hotfixid
        }
    }
}

foreach ($i in $ComputerName) {
    if ($PatchList) {
        foreach ($patch in $PatchList) {
            $value = Get-UpdateList -ComputerName $i -Patch $patch
            if ($value) {
                "$i - $value is present" | Write-Host -ForegroundColor Green
            } elseif (!($PresentOnly)) {
                "$i - $patch not present" | Write-Host -ForegroundColor Red
            }
        }
    } else {
        Get-UpdateList -ComputerName $i
    }
} 
