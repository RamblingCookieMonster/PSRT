Function Get-RTTicketEntry {
<#
.SYNOPSIS
    GET RT ticket history entry
.DESCRIPTION
    GET RT ticket history entry
.EXAMPLE
    Get-RTTicketHistory -Ticket 9507 -entry 2083827
#>
    [cmdletbinding()]
    Param ( 
        [Parameter( 
            Mandatory = $true, 
            ValueFromPipeLine = $true, 
            ValueFromPipelineByPropertyName = $true 
        )] 
        [ValidateNotNull()] 
        [Microsoft.PowerShell.Commands.WebRequestSession] 
        $Session,
        [ValidateNotNull()] 
        [string]$BaseUri,
        [string]$Ticket,
        [string]$Entry
    )
    $uri = Join-Parts -Separator '/' -Parts $BaseUri, "REST/1.0/ticket/$Ticket/history/id/$Entry"
    ( Invoke-WebRequest -Uri $uri -WebSession $Session ).Content
}