Function Find-RTTicket {
    <#
    .SYNOPSIS
        Find RT tickets with a specified query
    .DESCRIPTION
        Find RT tickets with a specified query
    .PARAMETER Query
        Query string to pass to RT

        Details: https://rt-wiki.bestpractical.com/wiki/REST#Ticket_Search
    .PARAMETER Expand
        If specified, pull ticket information for each ticket returned by this query
    .PARAMETER Referer
        Referer to use for whitelisting purposes.  Defaults to PSRTConfig.Referer (Created by New-RTSession)
        
        See @ReferrerWhitelist RT configuration if you run into CSRF errors
        If you specify  'https://<hostname>', RT (and its whitelist) use <hostname>:443
    .PARAMETER Session
        RT session to use.  Defaults to PSRTConfig.Session (Created by New-RTSession)
    .PARAMETER BaseUri
        Base URI for RT.  Defaults to PSRTConfig.BaseUri (Created by New-RTSession)
    .PARAMETER Raw
        If specified, do not parse output
    .EXAMPLE
        Find-RTTicket -Query "Created > '3 days ago'"
    .EXAMPLE
        Find-RTTicket -Query "Owner='wframe' AND Status='new'" -Referer http://WhiteListedHostname
    .EXAMPLE
        Find-RTTicket -Query "Status='new'" -Expand
    .FUNCTIONALITY
        Request Tracker
    #>
    [cmdletbinding()]
    Param(
        [parameter(Position = 1)]
        [string]$Query,

        [string]$Referer = $PSRTConfig.Referer,

        [switch]$Expand,

        [Parameter( ValueFromPipeLine = $true, 
            ValueFromPipelineByPropertyName = $true )] 
        [ValidateNotNull()] 
        [Microsoft.PowerShell.Commands.WebRequestSession] 
        $Session = $PSRTConfig.Session,
        [ValidateNotNull()] 
        [string]$BaseUri = $PSRTConfig.BaseUri,
        [switch]$Raw
    )
    Add-Type -AssemblyName System.Web
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    $InvokeParams = @{ WebSession = $Session; UseBasicParsing = $true }
    if($Referer)
    {
        $headers = @{}
        $headers.Add('Referer', $Referer)
        $InvokeParams.Add('Headers', $headers)
    }
    $Query = [System.Web.HttpUtility]::UrlEncode($Query)
    $uri = Join-Parts -Separator '/' -Parts $BaseUri, "/REST/1.0/search/ticket?query=$Query"

    $Response = ( Invoke-WebRequest @InvokeParams -Uri $uri).Content
    if ($Raw) {
        $Response
    }
    else {
        $Tickets = ConvertFrom-RTResponse -Content $Response
        if($Expand)
        {
            'Raw', 'Query', 'Referer', 'Expand'| Foreach { [void]$PSBoundParameters.Remove($_) }
            
            # Run a Get-RTTicket on every ticket returned from the Query, then store in sorted hash
            $Tickets.PSObject.Properties.Name |
                Where {$_ -match "\d+"} |
                ForEach-Object {
                    Write-Verbose "Fetching info on Ticket # $_"
                    Get-RTTicket @PSBoundParameters -Ticket $_
                }
        }
        else
        {
            $Tickets
        }
    }
}
