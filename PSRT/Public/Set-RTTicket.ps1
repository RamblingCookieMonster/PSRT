Function Set-RTTicket {
    <#
    .SYNOPSIS
        Edit a ticket in RT
    .DESCRIPTION
        Edit a ticket in RT

        Minimal testing.  Use at your own risk
    .PARAMETER Ticket
        Ticket ID
    .PARAMETER Requestor
        Ticket requestor
    .PARAMETER Owner
        Ticket Owner
    .PARAMETER Priority
        Ticket Priority
    .PARAMETER Subject
        Ticket Subject
    .PARAMETER Queue
        Ticket Queue
    .PARAMETER Status
        Ticket Status
    .PARAMETER InputHash
        Add additional ticket properties to edit in this hashtable.

        These values are overridden if an explicit parameter is also specified.  e.g.
            -Subject TITLE -InputObject @{Subject = 'Nope'}
            Result: Subject: TITLE
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
    .PARAMETER Force
        If specified, skip prompts
    .EXAMPLE
        Set-RTTicket -Ticket 123456 -Subject 'New Title!'
    .EXAMPLE
        Set-RTTicket -Ticket 123456 -InputHash @{
            Status = 'Waiting'
            Queue = 'SomeNewQueue'
        }

    .FUNCTIONALITY
        Request Tracker
    #>
    [cmdletbinding(SupportsShouldProcess=$true)]
    Param(
        [Alias('ID')]
        [ValidatePattern('^\d+$')]
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Ticket,
        [string]$Requestor,
        [string]$Owner,
        [int]$Priority = 0,
        [string]$Subject,
        [string]$Queue,
        [hashtable]$InputHash,
        [string]$Cc,
        [string]$AdminCc,
        [string]$Status,
        [string]$Referer = $PSRTConfig.Referer,

        [Parameter( ValueFromPipeLine = $true, 
            ValueFromPipelineByPropertyName = $true )] 
        [ValidateNotNull()] 
        [Microsoft.PowerShell.Commands.WebRequestSession] 
        $Session = $PSRTConfig.Session,
        [ValidateNotNull()] 
        [string]$BaseUri = $PSRTConfig.BaseUri,
        [switch]$Raw,
        [switch]$Force
    )
    Process
    {
        $InvokeParams = @{ WebSession = $Session }
        if($Referer)
        {
            $headers = @{}
            $headers.Add('Referer', $Referer)
            $InvokeParams.Add('Headers', $headers)
        }
        $uri = Join-Parts -Separator '/' -Parts $BaseUri, "/REST/1.0/ticket/$Ticket/edit"
    
        # Merge explicit parameters into InputHash, with explicit param values taking precedent
        $Parameters = . Get-ParameterValues
        if(-not $PSBoundParameters.ContainsKey('InputHash'))
        {
            $InputHash = @{}
        }
        Write-Output Requestor,
                     Owner,
                     Priority,
                     Subject,
                     Queue,
                     Cc,
                     AdminCc,
                     Status |
            Foreach-Object {
                $Property = $_
                if($Parameters.containskey($Property))
                {
                    $InputHash.Set_Item($Property, $Parameters[$Property])
                }
            }
    
        # Build up content for ticket
        # Queue must come last.  wtf RT. https://stackoverflow.com/a/29540271
        $Content = ''
        foreach($Key in $InputHash.Keys)
        {
            if($Key -ne 'Queue')
            {
                $Content += "$Key`: $($InputHash[$Key])`n"
            }
            #Later: Handle odd custom fields
        }
        if($InputHash.ContainsKey('Queue'))
        {
            $Content += "Queue: $($InputHash['Queue'])`n"
        }

        $InvokeParams.Add('Body', @{content=$Content})
        Write-Verbose "$($InvokeParams | Out-String)`n$($Content | Out-String)"

        if( ($Force -and -not $WhatIf) -or
            $PSCmdlet.ShouldProcess( "Set ticket $Ticket with content $($Content | Out-String)".trim(),
                                     "Set ticket $Ticket with content $($Content | Out-String)`?".trim(),
                                     "Setting Ticket".trim() )) {
            $Response = ( Invoke-WebRequest @InvokeParams -Uri $uri -Method Post).Content
            if ($Raw) {
                $Response
            }
            else {
                ConvertFrom-RTResponse -Content $Response
            }
        }
    }
}
