Function Invoke-RTSearch {
    <#
.SYNOPSIS
    Invoke RT Search
.DESCRIPTION
    Invoke RT Search
.PARAMETER Query
    Query string (in quotes) to pass to RT
.PARAMETER Session
    RT session to use.  Defaults to PSRTConfig.Session (Created by New-RTSession)
.PARAMETER BaseUri
    Base URI for RT.  Defaults to PSRTConfig.BaseUri
.PARAMETER Raw
    If specified, do not parse output
.EXAMPLE
    Invoke-RTSearch -Query "Created > '3 days ago'"
.FUNCTIONALITY
    Request Tracker
#>
    [cmdletbinding()]
    Param(
        [parameter(Position = 1)]
        [string]$Query,

        [Parameter( ValueFromPipeLine = $true, 
            ValueFromPipelineByPropertyName = $true )] 
        [ValidateNotNull()] 
        [Microsoft.PowerShell.Commands.WebRequestSession] 
        $Session = $PSRTConfig.Session,
        [ValidateNotNull()] 
        [string]$BaseUri = $PSRTConfig.BaseUri,
        [switch]$Raw
    )
    $headers = @{}
    $headers.Add('Referer', "$BaseUri")
    $uri = Join-Parts -Separator '/' -Parts $BaseUri, "/REST/1.0/search/ticket?query=$Query"
    $Response = ( Invoke-WebRequest -Uri $uri -WebSession $Session -Headers $headers).Content
    if ($Raw) {
        $Response
    }
    else {
        ConvertFrom-RTResponse -Content $Response
    }
}
