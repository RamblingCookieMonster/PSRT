Function Get-RTTicket {
<#
.SYNOPSIS
    GET RT Ticket overview.
.DESCRIPTION
    GET RT Ticket overview.
.EXAMPLE
    Get-RTTicket -Ticket 9507
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
    $uri = Join-Parts -Separator '/' -Parts $BaseUri, "REST/1.0/ticket/$Ticket"
    ( Invoke-WebRequest -Uri $uri -WebSession $Session ).Content
}