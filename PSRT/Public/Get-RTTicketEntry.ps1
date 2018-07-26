Function Get-RTTicketEntry {
<#
.SYNOPSIS
    GET RT ticket history entry
.DESCRIPTION
    GET RT ticket history entry.  If an entry is not specified, we list the RT ticket history
.PARAMETER Ticket
    Ticket to query
.PARAMETER Entry
    Optional entry to query for.  If not specified, we list all entry numbers in the ticket history
.PARAMETER Session
    RT session to use.  Defaults to PSRTConfig.Session (Created by New-RTSession)
.PARAMETER BaseUri
    Base URI for RT.  Defaults to PSRTConfig.BaseUri
.PARAMETER Raw
    If specified, do not parse output
.EXAMPLE
    Get-RTTicket -Ticket 9507
.EXAMPLE
    Get-RTTicketHistory -Ticket 9507 -entry 2083827
.FUNCTIONALITY
    Request Tracker
#>
    [cmdletbinding()]
    Param(
        [parameter(Position = 1)]
        [string]$Ticket,
        [string]$Entry,

        [Parameter( ValueFromPipeLine = $true, 
                    ValueFromPipelineByPropertyName = $true )] 
        [ValidateNotNull()] 
        [Microsoft.PowerShell.Commands.WebRequestSession] 
        $Session = $PSRTConfig.Session,
        [ValidateNotNull()] 
        [string]$BaseUri = $PSRTConfig.BaseUri,
        [switch]$Raw
    )
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    $Ticket = $Ticket.TrimStart('#').TrimStart('RT')
    $uri = Join-Parts -Separator '/' -Parts $BaseUri, "REST/1.0/ticket/$Ticket/history/id/$Entry"
    $Response = ( Invoke-WebRequest -Uri $uri -WebSession $Session -UseBasicParsing ).Content
    if($Raw)
    {
        $Response
    }
    else
    {
        ConvertFrom-RTResponse -Content $Response
    }
}
