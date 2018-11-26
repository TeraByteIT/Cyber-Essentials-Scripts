#requires -version 2

Function Get-OSCInstalledApplication
{
<#
 	.SYNOPSIS
        Get-OSCInstalledApplication is a function which can be used to get installed application on local or remote computer.
    .DESCRIPTION
        Get-OSCInstalledApplication is a function which can be used to get installed application on local or remote computer.
    .PARAMETER  ComputerName
		Gets the installed application on the specified computers. 
    .PARAMETER  ComputerFilePath
		Specifies the path to the CSV file. This file should contain one or more computers. 
    .EXAMPLE
        C:\PS>Import-Module .\Get-InstalledApplicationInfo.psm1
        C:\PS> Get-OSCInstalledApplication -ComputerName localhost
		
		This command will list installed application on the current machine
    .EXAMPLE
        C:\PS> Get-OSCInstalledApplication -ComputerFilePath C:\Script\ComputerList.csv
		
		This command specifies the path to an item that contains several computers. Then 'Get-OSCInstalledApplication' cmdlet will list installed application from thoese computers.
    .EXAMPLE
        C:\PS> Get-OSCInstalledApplication -ComputerName localhost | Export-Csv -Path C:\installedApps.csv
		
		This command will list installed application on the local machine and saves the strings in a CSV file.
#>
    [CmdletBinding(DefaultParameterSetName='SinglePoint')]
    Param
    (
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="SinglePoint")]
        [Alias('CName')][String[]]$ComputerName,
        [Parameter(Mandatory=$true, Position=0, ParameterSetName="MultiplePoint")]
        [Alias('CNPath')][String]$ComputerFilePath
    )
    
    If($ComputerName)
    {
        Foreach($CN in $ComputerName)
        {
            #test compter connectivity
            $PingResult = Test-Connection -ComputerName $CN -Count 1 -Quiet
            If($PingResult)
            {
                FindInstalledApplicationInfo -ComputerName $CN
            }
            Else
            {
                Write-Warning "Failed to connect to computer '$ComputerName'."
            }
        }
    }

    If($ComputerFilePath)
    {
        $ComputerName = (Import-Csv -Path $ComputerFilePath).ComputerName

        Foreach($CN in $ComputerName)
        {
            FindInstalledApplicationInfo -ComputerName $CN
        }
    }
}

Function FindInstalledApplicationInfo($ComputerName)
{
    $Objs = @()
    $RegKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    
    $InstalledAppsInfos = Get-ItemProperty -Path $RegKey

    Foreach($InstalledAppsInfo in $InstalledAppsInfos)
    {
        $Obj = [PSCustomObject]@{Computer=$ComputerName;
                                 DisplayName = $InstalledAppsInfo.DisplayName;
                                 DisplayVersion = $InstalledAppsInfo.DisplayVersion;
                                 Publisher = $InstalledAppsInfo.Publisher}
        $Objs += $Obj
    }
    $Objs | Where-Object { $_.DisplayName } 
}