
function Invoke-RTQuery {
<#
.Synopsis
   Send a query to RT server returns object
.DESCRIPTION
   Send a RT Rest Query to RT Server and returns Object.
.EXAMPLE
    $q="search/ticket?query=(Status='open') AND (Queue='Support')&format=l&fields=Subject,Status,Priority,CF.{Category},Owner,Creator"   
    Connect-RequestTracker -Credential $cred -Server "rt.mydomain.com"|Get-RequestTrackerQuery -Server "rt.mydomain.com" -Query $q
.INPUTS
    Query string
.OUTPUTS
    PSOBject
.NOTES
    Need to use &format=l(multi-line) in query  format=s (Short ticket & subject) and form=i (ticket/ticketID)
#>
    [cmdletbinding()]
    Param ( 
        [Parameter( 
            Mandatory = $true, 
            ValueFromPipeLine = $true, 
            ValueFromPipelineByPropertyName = $true 
        )] 
        [ValidateNotNull()] 
        [Microsoft.PowerShell.Commands.WebRequestSession]$Session,
        [Parameter(Mandatory = $true)] 
        [ValidateNotNull()] 
        [string]$Server, 
        [string]$VirtualDir="/rt/",
        [ValidateNotNull()] 
        [string]$Query,
        [switch]$NoSSL
    )
    if ($NoSSL){
        $http="http://"
    }else{
        $http="https://"
    }
    
    $uri=$http + $Server + $VirtualDir + "REST/1.0/" + $Query
    $RT=Invoke-WebRequest -Uri  $uri -WebSession $Session


    [System.Collections.ArrayList]$tickets=$RT.Content.Split("`n")

    $arr=@()
    $blnNewRecord=$true
    $blnNotFirst=$false
    foreach ($line in $tickets){
        if ($blnNotFirst -and $blnNewRecord){
            $Object=New-Object PSObject -Property $hash
            $arr+=$Object    
            $hash=[ordered]@{}    
            $blnNewRecord=$false
        }elseif(!$blnNotFirst){
            $hash=[ordered]@{}    
            $blnNewRecord=$false
            $blnNotFirst=$true
        }   
        if ($line -match "(.*):\s+(.*)"){
            $hash.Add($Matches[1],$Matches[2])
        }
        if ($line -match "--"){
            $blnNewRecord=$true
        }
    }
    return $arr
}