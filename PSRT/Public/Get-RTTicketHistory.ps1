Function Get-RTTicketHistory {
<#
.SYNOPSIS
   GET RT ticket history
.DESCRIPTION
   GET RT ticket history
.EXAMPLE
    Get-RTTicketHistory -Ticket 9507
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
        [string]$Ticket
    )
    $uri = Join-Parts -Separator '/' -Parts $BaseUri, "REST/1.0/ticket/$Ticket/history"
    ( Invoke-WebRequest -Uri $uri -WebSession $Session ).Content
}