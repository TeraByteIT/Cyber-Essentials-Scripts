#requires -version 2

Function Get-MissingWindowsUpdates
{
<#
 	.SYNOPSIS
        Get-MissingWindowsUpdates is an function which can be used to search for missing windows updates on local or remote computer.
    .DESCRIPTION
        Get-MissingWindowsUpdates is an function which can be used to search for missing windows updates on local or remote computer.
    .PARAMETER  ComputerName
		Gets missing Windows updates on the specified computers. 
    .PARAMETER  ComputerFilePath
		Specifies the path to the CSV file. This file should contain one or more computers. 
    .EXAMPLE
        C:\PS>Import-Module .\Get-MissingWindowsUpdates.psm1
        C:\PS> Get-MissingWindowsUpdates -ComputerName localhost
		
		This command will list all the missing windows updates on the current machine that the script is being ran from
    .EXAMPLE
        C:\PS> Get-MissingWindowsUpdates -ComputerFilePath C:\Scripts\ComputerList.csv
		
		This command specifies the path to an item that contains several computers. Then the 'Get-MissingWindowsUpdates' cmdlet will list all the missing windows updates from thoese computers.
    .EXAMPLE
        C:\PS> Get-MissingWindowsUpdates -ComputerName localhost | Export-Csv -Path C:\installedApps.csv
		
		This command will list all the missing windows updates on the current machine and saves the strings in a CSV file.
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
                FindMissingUpdates -ComputerName $CN
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
            FindMissingUpdates -ComputerName $CN
        }
    }
}

Function FindMissingUpdates($ComputerName)
{
    $UpdateSession = New-Object -ComObject Microsoft.Update.Session
    $UpdateSearcher = $UpdateSession.CreateupdateSearcher()
    $Updates = @($UpdateSearcher.Search("IsHidden=0 and IsInstalled=0").Updates)
    $Updates | Select-Object Title 
}