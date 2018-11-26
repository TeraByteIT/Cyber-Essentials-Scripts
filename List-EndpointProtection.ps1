<#
.SYNOPSIS
	Name: List-EndpointProtection.ps1
	This script will detect and list what endpoint protection product is currently used alongside Windows, if any
	
.DESCRIPTION
    The purpose of this script is to obtain information on what endpoint proteciton product is being used, if any.
    
.NOTES
	Author:	 Marcus Dempsey
	Created: 26/11/2018
	Updated: 26/11/2018
	Version: 1.0

.EXAMPLE
	List-EndpointProtection
#>

Function List-EndpointProtection {
    Write-Host "Searching for installed and configured endpoint protection products, this may take a minute..`n" -ForegroundColor Cyan
    Try {
        $EndPointProducts = Get-WmiObject -Namespace "root\SecurityCenter2" -Class AntiVirusProduct;        
        ForEach ($EPApp in $EndPointProducts) {
            $EndPoint_Name   = $EPApp.displayName;
            $EndPoint_Status = $EPApp.productState;
            Write-Host "Detected endpoint protection product '$EndPoint_Name'" -ForegroundColor Yellow					
            Switch ($EndPoint_Status) {
                "262144" {$EndPoint_Status_Definitions = "Up to date";  $EndPoint_Status_RealTimeProtection = "Disabled";}
                "262160" {$EndPoint_Status_Definitions = "Out of date"; $EndPoint_Status_RealTimeProtection = "Disabled";}
                "266240" {$EndPoint_Status_Definitions = "Up to date";  $EndPoint_Status_RealTimeProtection = "Enabled";}
                "266256" {$EndPoint_Status_Definitions = "Out of date"; $EndPoint_Status_RealTimeProtection = "Enabled";}
                "393216" {$EndPoint_Status_Definitions = "Up to date";  $EndPoint_Status_RealTimeProtection = "Disabled";}
                "393232" {$EndPoint_Status_Definitions = "Out of date"; $EndPoint_Status_RealTimeProtection = "Disabled";}
                "393472" {$EndPoint_Status_Definitions = "Up to date";  $EndPoint_Status_RealTimeProtection = "Disabled";}
                "393488" {$EndPoint_Status_Definitions = "Out of date"; $EndPoint_Status_RealTimeProtection = "Disabled";}
                "397312" {$EndPoint_Status_Definitions = "Up to date";  $EndPoint_Status_RealTimeProtection = "Enabled";}
                "397328" {$EndPoint_Status_Definitions = "Out of date"; $EndPoint_Status_RealTimeProtection = "Enabled";}
                "397568" {$EndPoint_Status_Definitions = "Up to date";  $EndPoint_Status_RealTimeProtection = "Enabled";}
                "397584" {$EndPoint_Status_Definitions = "Out of date"; $EndPoint_Status_RealTimeProtection = "Enabled";}
                Default {$EndPoint_Status_Definitions  = "Unknown";     $EndPoint_Status_RealTimeProtection = "Unknown";}
            }            
            If ($EndPoint_Status_Definitions -eq "Out of  date" -or $EndPoint_Status_Definitions -eq "Unknown") {
                Write-Host "`tProduct definitions        : $EndPoint_Status_Definitions" -ForegroundColor Red
            }
            else {
                Write-Host "`tProduct definitions        : $EndPoint_Status_Definitions" -ForegroundColor Green
            }
            If ($EndPoint_Status_RealTimeProtection -eq "Disabled" -or $EndPoint_Status_RealTimeProtection -eq "Unknown") {
                Write-Host "`tReal-time protection status: $EndPoint_Status_RealTimeProtection" -ForegroundColor Red
            }
            else
            {
                Write-Host "`tReal-time protection status: $EndPoint_Status_RealTimeProtection" -ForegroundColor Green
            }
            Write-Host ""
        }
    }
    finally { }
}

List-EndpointProtection;