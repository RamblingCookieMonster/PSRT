Function Get-RTTicket {
<#
.SYNOPSIS
    GET RT Ticket overview
.DESCRIPTION
    GET RT Ticket overview
.PARAMETER Ticket
    Ticket to query
.PARAMETER Session
    RT session to use.  Defaults to PSRTConfig.Session (Created by New-RTSession)
.PARAMETER BaseUri
    Base URI for RT.  Defaults to PSRTConfig.BaseUri
.PARAMETER Raw
    If specified, do not parse output
.EXAMPLE
    Get-RTTicket -Ticket 9507
.FUNCTIONALITY
    Request Tracker
#>
    [cmdletbinding()]
    Param(
        [parameter(Position = 1)]
        [string]$Ticket,

        [Parameter( ValueFromPipeLine = $true, 
                    ValueFromPipelineByPropertyName = $true )] 
        [ValidateNotNull()] 
        [Microsoft.PowerShell.Commands.WebRequestSession] 
        $Session = $PSRTConfig.Session,
        [ValidateNotNull()] 
        [string]$BaseUri = $PSRTConfig.BaseUri,
        [switch]$Raw
    )
    $Ticket = $Ticket.TrimStart('#').TrimStart('RT')
    $uri = Join-Parts -Separator '/' -Parts $BaseUri, "REST/1.0/ticket/$Ticket"
    $Response = ( Invoke-WebRequest -Uri $uri -WebSession $Session ).Content
    if($Raw)
    {
        $Response
    }
    else
    {
        ConvertFrom-RTResponse -Content $Response
    }
}